Calculation of how much more efficient a blockchain can be if its bonds are split into 2 types.

For any blockchain protocol, if you double spending on security, then you are also doubling the cost to attack. 

Similarly in home security, if you build your walls twice as thick, it will cost twice as much to build, and it costs twice as much to penetrate.
When looking at the efficiency of a home security strategy, you are interested in the cost to rob the house, divided by the cost to build and maintain the security system.
When looking at the "security efficiency" of a blockchain consensus protocol, we are interested in the cost to attack the system, divided by the cost to maintain the system.

Doubling the gas in a car's tank makes it drive twice as far.
When we compare cars, we look at miles per gallon, called "fuel efficiency". How much you spend to run the car divided by how far you can drive it.
When we compare consensus protocols, we look at "security efficiency". Which is how much you would need to spend to successfully attack the consensus protocol divided by the cost to maintain consensus for a day.

`SecurityEfficiency(Blockchain) = CostAttack(Blockchain) / CostConsensus(Blockchain)`

Blockchain A has 1 type of bond. `1 >= X > 0`.
where X is the portion of the value on the blockchain that is in bonds.

Blockchain B has 2 types of bonds. `1 > L > S > 0`, `L + S <= 1`.
Where L is the portion of the value on the blockchain in the big bond.
and S is the portion of the value on the blockchain in the small bond.
In the case of Flying Fox, `L / S = 128`

The interest rate is R. For Blockchain B, the interest rate only applies to the smaller bond which is locked up as a security deposit. Since the big bond is spendable, we don't lose value by the interest rate.

`CostConsensus(A) = X * R`.

`CostConsensus(B) = S * R`.

`CostConsensus(A)/CostConsensus(B) = (S/X)`.

For blockchain B, the attack needs to be agreed upon by a majority of the large bond, because the validators are chosen from among them. For A, there is only one bond, and the validators are chosen from it.

`CostAttack(A) = X / 2`.

`CostAttack(B) = L / 2`.

`CostAttack(A) / CostAttack(B) = X / L`.


`SecurityEfficiency(A) = X / (2 * X * R) = 1 / (2 * R)`

`SecurityEfficiency(B) = L / (2 * S * R) = L / (2 * R * S)`

`SecurityEfficiency(A) / SecurityEfficiency(B) = S / L`.


In the case of flying fox, `L / S = 128`, so the 2-bond blockchain has 128 times higher efficiency than the 1-bond blockchain.

So, given the same operating costs, Flying Fox can secure a market cap that is 128 times larger than bonded proof of stake systems that only have 1 type of bond.

[explanation for why 2 types of bonds is so much more efficient](2_types_of_bonds.md)

