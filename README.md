# Voting with Blockchains
Code for the paper Conduction trustworthy and user friendly elections in large Democracies  </br>

We propose new ways to conduct elections using blcokchains following important practices in order to preserve democratic principles.

## Actors
### Voters
Voters vote for the candidates.

### Candidates
Candidates contest in the elections.

### Admin / Election Commission
Election commission facilitates the elections.

## HCA & HPA 
There are two proposed solutions Hidden coin approach (HCA) and hidden party approach (HPA). For more details refer to paper [here](https://drive.google.com/file/d/1lWbIaWt9c-WdDpBQ8MHzrK2hl3NO7aqD/view?usp=sharing)

To test in truffle

- Compile:
```bash
truffle compile
```
- Open console in development mode:
```bash
truffle develop
```

- Deploy
```bash
truffle deploy
```

- Start contract
```bash
let instance = await Marketplace.deployed()
```

- Call a function
```bash
instance.function(args)
```

- Get a mapping:
```bash
var balance = await instance.<mapping name>.call(account);
console.log(balance);
```

Documentation can be found [here](https://writemd.xyz/p/638776947b6854401)

