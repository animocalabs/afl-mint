// This script is used to add a Vault resource to their account so that they can use FiatToken 
//
// If the Vault already exist for the account, the script will return immediately without error
// 
// If not onchain-multisig is required, pubkeys and key weights can be empty
// Vault resource must follow the FuntibleToken interface where initialiser only takes the balance
// As a result, the Vault owner is required to directly add public keys to the OnChainMultiSig.Manager
// via the `addKeys` method in the OnchainMultiSig.KeyManager interface.
// 
// Therefore if multisig is required for the vault, the account itself should have the same key weight
// distribution as it does for the Vault.
import FungibleToken from 0x9a0766d93b6608b7
import FiatToken from 0xa983fecbed621163


transaction() {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a FiatToken Vault
        if signer.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath) == nil {
             // Create a new ExampleToken Vault and put it in storage
            signer.save(
                <-FiatToken.createEmptyVault(),
                to: FiatToken.VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            signer.link<&FiatToken.Vault{FungibleToken.Receiver}>(
                FiatToken.VaultReceiverPubPath,
                target: FiatToken.VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the UUID() function through the VaultUUID interface
            signer.link<&FiatToken.Vault{FiatToken.ResourceId}>(
                FiatToken.VaultUUIDPubPath,
                target: FiatToken.VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&FiatToken.Vault{FungibleToken.Balance}>(
                FiatToken.VaultBalancePubPath,
                target: FiatToken.VaultStoragePath
            )   
        }

    }
}