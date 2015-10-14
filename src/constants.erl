-module(constants).
-compile(export_all).
%-export([export_all]).
-define(InitialCoins, round(math:pow(2, 48)) - 1).
initial_coins() -> ?InitialCoins.
initial_delegation() -> 1.
finality() -> 26.%/docs/security.py explains why.
validators_elected_per_block() -> 54.
minimum_validators_per_block() -> 36.
chances_per_address() -> 200. %Each address has this many chances to be a validator per block. this makes it possible to be validator more than once on the same block. 
master_pub() -> <<"BOKw6lcRJzGkZ3G2k+T1kEeZFn8DC+awTIE3wnRAi8Jstp9PUvLyuCE6H+A79SD85cxFddVmWSiZIaPxxcbW2Zg=">>.
max_size() -> 200000000000.%should be 200 gigabytes, does not include old blocks.
-define(ConsensusBytePrice, initial_coins() div max_size()).%instead we should have a maximum number of bytes per block, and garbage collect old blocks.
consensus_byte_price() -> ?ConsensusBytePrice.
-define(MinReveal, finality() + 1).
min_reveal() -> ?MinReveal.
-define(MaxReveal, finality()*10).
max_reveal() -> ?MaxReveal.
-define(MaxAddress, max_size() div 10 div 85).%use about 10% of space to store addresses. Each one is 75 bytes
max_address() -> ?MaxAddress.
-define(MaxChannel, max_size() div 10 div 9).%use about 10% of space to store addresses. Each one is 9 bytes
max_channel() -> ?MaxChannel.
create_channel_fee() -> consensus_byte_price() * 9.
create_account_fee() -> consensus_byte_price() * 75.
delete_account_reward() -> create_account_fee() * 3 div 4. % 3/4th refund.
security_ratio() -> 1.5.
-define(SecurityBondsPerWinner, fractions:new(1, 1000 * finality() * minimum_validators_per_block())). 
security_bonds_per_winner() -> ?SecurityBondsPerWinner.% so around 1% of money is locked up at a time, and it takes around 4000 blocks to move all the money. %this money goes from validators, to themselves. 
-define(AccountFee, fractions:new(1, max_address() * finality() * 10)).%so if all accounts are full, it takes 10 finalities until most of them start losing so much money that their accounts open up. 
account_fee() -> ?AccountFee. 
-define(DelegationFee, fractions:new(finality() * 1000 - 1, finality() * 1000)).%so it would take about 15,000 blocks to lose 1/2 your money. So you have about 350,000 chances to be validator till you lose 1/2 your money. So you need at least initial_coins()/350000 in delegation to be able to profitably validate. Which means it supports up to 350000 validators at a time max.
delegation_fee() -> ?DelegationFee.
delegation_reward() -> fractions:subtract(function:new(1, 1), ?DelegationFee).
block_creation_fee() -> fractions:new(1, 20000).%Which implies finality only has to be 13 blocks long!!!
%It is important that 1/3 of the block_creation_fee be less than 2/3 of the validator's bond.
%-define(PBCFV, fractions:multiply_int(block_creation_fee(), initial_coins()) div 3).
-define(PBCFV, fractions:multiply(block_creation_fee(), fractions:new(1, 3*validators_elected_per_block()))).
portion_of_block_creation_fee_validators() -> ?PBCFV.
test() ->
    A = portion_of_block_creation_fee_validators(), 
    B = security_bonds_per_winner()*minimum_validators_per_block(),
    true = A < B / 2,
    %If this isn't truth, then it the validators will sign up to validate even if they can't actually show up.
    success.

%(All the money in channels, times this fee) is the amount of money that transfers from delegates who were not elected to delegates who are elected in each block, and gets locked up for finality() blocks. If this number is too high, then poor people can't afford to be validators. If this number is too low, then rich people can't move their money quickly enough.


%<<"BHtLfya6JUNuLXOJ2pGXkyOevYeeyTC5kxzMlB4RTS0DAtqDLxxa0Phb5lBd4oZludcAZzjKXvo8QtdWeJ30gLc=">>.

