defmodule TxCreator do
  def nonce(pub) do
    a=Mempool.txs
    |> Enum.filter(fn(tx) -> tx.data.pub == pub end)
    |> length
    a+KV.get(pub).nonce
  end
	def broadcast(tx) do tx |> Keys.sign |> Mempool.add_tx end
  def spend(to, amount) do
    pub = Keys.pubkey
    balance = KV.get(pub).amount
		fee = 10000
    if balance < (amount + fee) do
			IO.puts("warning, you cannot afford to spend this tx, so it wont be valid")
		end
		to_now = KV.get(to)
		create = (to_now == nil)
    %Spend{to: to, amount: amount, nonce: nonce(pub), fee: fee, create: create, pub: pub} 
    |> broadcast
  end
  def sign do
    pub = Keys.pubkey
    acc = KV.get(pub)
    if acc.bond > Constants.min_bond do
      h=KV.get("height")
      if h<1 do prev_hash=nil else
        prev_hash = Blockchain.blockhash(Blockchain.get_block(h))
      end
      tot_bonds = KV.get("tot_bonds")
      w = Enum.filter(0..Constants.chances_per_address, fn(x) -> Sign.winner?(acc.bond, tot_bonds, Sign.rng(prev_hash), pub, x) end) 
      h = KV.get("height") + 1
      ran = KV.get("secret #{inspect h}")
      if ran == nil do
        ran = :crypto.rand_bytes(10)
        KV.put("secret #{inspect h}", ran)
      end
      secret = DetHash.doit(ran)
      %Sign{prev_hash: prev_hash, winners: w, secret_hash: secret, nonce: nonce(pub), height: h-1, pub: pub}
      |> broadcast
    end
  end
  def reveal do
    h = KV.get("height") - Constants.epoch
    cond do
      h < 2 -> nil
      true -> reveal_2(h)
    end
  end
  def reveal_2(h) do
    pub = Keys.pubkey
    old_block=Blockchain.get_block(h)
    old_tx = old_block.data.txs 
      |> Enum.filter(&(&1.data.__struct__ == :Elixir.Sign)) 
      |> Enum.filter(&(&1.data.pub == pub)) 
      |> hd
    w=old_tx.data.winners
    bond_size=old_block.data.bond_size
    secret = KV.get("secret #{inspect h}")
    if secret != nil do
      %Reveal{signed_on: h, 
              winners: w, 
              amount: length(w)*bond_size, 
              secret: KV.get("secret #{inspect h}"), 
              nonce: nonce(pub), pub: pub}
      |> broadcast
    end
  end
  def slasher(tx1, tx2) do
  end
  def to_channel(other, amount, amount2 \\ 0, delay \\ 10) do
		if KV.get(other) == nil do
			IO.puts("your partner doesn't exist yet, so this probably wont work")
		end
		is_ch = KV.get(ToChannel.key(Keys.pubkey, other))
		new = (is_ch == nil)
		tx = %ToChannel{amount: amount, amount2: amount2,	new: new,	pub: Keys.pubkey,	pub2: other}
		if new do
			tx2 = %{tx | delay: delay, nonce: nonce(Keys.pubkey)}
		else
			cond do
				is_ch.pub == Keys.pubkey  -> tx2 = %{ tx | to: "pub"} |> Keys.sign
				is_ch.pub2 == Keys.pubkey -> tx2 = %{ tx | to: "pub2"} |> Keys.sign2
				true -> IO.puts("that isn't your channel")
			end
		end
		tx2 |> broadcast
		#the channel should be updated in the channel manager.
  end
  def close_channel_fast(other, amount, amount2, bets \\ []) do
		c = ToChannel.key(Keys.pubkey, other)
		if KV.get(c) == nil do
			IO.puts("this channel doesn't exist yet, so you cannot close it.")
		end
		cb = KV.get(c)
		IO.puts("channel on blockchain #{inspect cb}")
		cb = %ChannelBlock{amount: amount,
											 amount2: amount2,
											 pub: cb.pub,
											 pub2: cb.pub2,
											 fast: true,
											 old_amount: cb.amount,
											 old_amount2: cb.amount2}
		if bets != [] do
			cb = %{cb | bets: bets}
		end
    cb |> Keys.sign
  end
  def close_channel_timeout(other) do
		c = ToChannel.key(Keys.pubkey, other)
		if KV.get(c) == nil do
			IO.puts("this channel doesn't exist yet, so you cannot close it.")
		end
		c = KV.get(c)
		if not(c.nonce > 0 and c.time < (KV.get("height") - c.delay)) do
			IO.puts("you need to wait longer. #{inspect c.time - (KV.get("height") - c.delay) + 1}")
		end
		IO.puts("channel on blockchain #{inspect c}")
		cb = %CloseChannel{pub: c.pub, pub2: c.pub2, type: "timeout", nonce: nonce(Keys.pubkey)}
    cb |> broadcast
  end
  def close_channel_slasher(tx) do
		other = [tx.data.pub, tx.data.pub2] |> Enum.filter(&(&1 != Keys.pubkey)) |> hd
		c = ToChannel.key(Keys.pubkey, other)
		if KV.get(c) == nil do
			IO.puts("this channel doesn't exist yet, so you cannot close it.")
		end
		c = KV.get(c)
		IO.puts("channel on blockchain #{inspect c}")
		cb = %CloseChannel{pub: c.pub, pub2: c.pub2, type: "slasher", channel_block: tx, nonce: nonce(Keys.pubkey)}
    cb |> broadcast
  end
	def channel_spend(other, amount, nonce \\ 1) do
		me = Keys.pubkey
		c = KV.get(ToChannel.key(Keys.pubkey, other))
		if c == nil do
			IO.puts("this channel doesn't exist yet, so you cannot close it.")
		end
		d = 1
		if me == c.pub do
			d = -1
		end
		channel = ChannelManager.get(other)
		new = %{c | amount: channel.amount - (d * amount),
			amount2: channel.amount2 + (d * amount),
			nonce: channel.nonce+1,
			old_amount: c.amount,
			old_amount2: c.amount2,
			nonce: nonce}
		if me == new.pub do
			new = Keys.sign(new)
		else
			new = Keys.sign2(new)
		end
		ChannelManager.update(other, new)
		new
	end
end