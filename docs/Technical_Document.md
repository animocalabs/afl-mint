## Technical Summary and Code Documentation

## Instructions for Create Template, Mint NFTs, buy Packs, and Open Packs

A common order of creating NFT would be

- Create new Template with `transactions/createNFTTemplate.cdc` using Admin Account.
- add new owner to get the flow payment `transactions/addNewOwner.cdc` using Admin Account.
- Create Receiver with `transaction/setupAccount.cdc`.
- buy Packs with `transaction/buyPackMint.cdc`.
- Open Pack with `transaction/openPack.cdc`.

You can also see the scripts in `scripts` to see how information
can be read from the AFLNFT, AFLPack and AFLAdmin contracts.

### AFLNFT, AFLPack and AFLAdmin Events

- Contract Initialized ->
  ` pub event ContractInitialized()`
  This event is emitted when the `AFLNFT` will be initialized.

- Event for Template creation ->
  `pub event TemplateCreated(templateId: UInt64, maxSupply: UInt64)`
  Emitted when a new Template will be created

- Event for Template Mint ->
  `pub event NFTMinted(nftId: UInt64, templateId: UInt64, mintNumber: UInt64)`
  Emitted when a Template will be Minted and save as NFT

- Event for buy Pack Created ->
  `pub event PackBought(templateId: UInt64, receiptAddress: Address?)`
  Emitted when a new Pack is purchased

- Event for Pack Opened ->
  `pub event PackOpened(nftId: UInt64, receiptAddress: Address?)`
  Emitted when a new Pack is opened

## AFLNFT Addresses

`AFLNFT`: This is the main AFLNFT smart contract that defines the core functionality of the NFT.

| Network | Contract Address     |
| ------- | -------------------- |
| Mainnet | `` |
| Testnet | `0x4ea480b0fc738e55` |

## AFLPack Addresses

`AFLPack.cdc`: This is the AFLPack smart contract that has the functionality of the packs.

| Network | Contract Address     |
| ------- | -------------------- |
| Mainnet | `` |
| Testnet | `0x4ea480b0fc738e55` |

### Deployment Contract on Emulator

- Run `flow project deploy --network emulator`
  - All contracts are deployed to the emulator.

After the contracts have been deployed, you can run the sample transactions
to interact with the contracts. The sample transactions are meant to be used
in an automated context, so they use transaction arguments and string template
fields. These make it easier for a program to use and interact with them.
If you are running these transactions manually in the Flow Playground or
vscode extension, you will need to remove the transaction arguments and
hard code the values that they are used for.
