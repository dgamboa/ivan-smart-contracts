### When executing the addEntity function, which design consumes the most gas (execution cost)?
The array version consumes 88779 in execution cost while the mapping version consumes 66375 in execution cost.

### Is it a significant difference? Why/why not?
The array version consumes significantly more gas because of the way dynamic arrays work. Mainly, the array will have to be expanded to include an additional entity every time we add one. This is computationally more expensive than simply adding an entity to a map where the entities already stored in the map don't have to change when we add a new one. 

### Add 5 Entities into storage using the addEntity function and 5 different addresses. Then update the data of the fifth address you used. Do this for both contracts and take note of the gas consumption (execution cost). Which solution consumes more gas and why?
Having to iterate through the array to find the right address to update makes it computationally more expensive. In Big O notation, this is a O(n) update algorithm whereas the map is updated in O(1) because we access the address as the key directly every time.

*Course solutions on GitHub [here](https://github.com/filipmartinsson/solidity-201/tree/master/storage_design)*
