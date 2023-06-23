# Setup Paths Guide

## Instructions

### Test

Uniswap V3

- [ ] Add new path in `test/config/Paths.single.t.sol` or other path files
- [ ] Add fee info in `test/config/Fees.t.sol`, if the fee is lower than 0.3%

Balancer

- [ ] Add new path in `test/config/Paths.single.t.sol` or other path files
- [ ] Add pool info in `test/config/Pools.t.sol`

BancorV2

- [ ] Add new path in `test/config/Paths.single.t.sol` or other path files, but only put the sell token and buy token in the path, cause the `BancorV2Dex` will search the corresponding path for the pair.
