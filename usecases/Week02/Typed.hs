{-# LANGUAGE DataKinds           #-} -- Enable datatype promotions
{-# LANGUAGE FlexibleContexts    #-} -- Enable flexible contexts, implied by ImplicitParams
{-# LANGUAGE NoImplicitPrelude   #-} -- Don't load native Prelude, to avoid conflicts with PlutusTx.Prelude
{-# LANGUAGE OverloadedStrings   #-} -- https://riptutorial.com/haskell/example/4173/overloadedstrings
{-# LANGUAGE ScopedTypeVariables #-} -- Enable lexical scoping of type variables explicit introduced with forall
{-# LANGUAGE TemplateHaskell     #-} -- Enable Template Haskell splice and quotation syntax
{-# LANGUAGE TypeApplications    #-} -- Allow the use of type application syntax
{-# LANGUAGE TypeFamilies        #-} -- Allow the use and definition of indexed type and data families
{-# LANGUAGE TypeOperators       #-} -- Allow the use and definition of types with operator names

{-# OPTIONS_GHC -fno-warn-unused-imports #-}

module Week02.Typed where

import           Control.Monad        hiding (fmap)
import           Data.Map             as Map
import           Data.Text            (Text)
import           Data.Void            (Void)
import           Plutus.Contract
import           PlutusTx             (Data (..))
import qualified PlutusTx
import qualified PlutusTx.Builtins    as Builtins
import           PlutusTx.Prelude     hiding (Semigroup(..), unless)
import           Ledger               hiding (singleton)
import           Ledger.Constraints   as Constraints
import qualified Ledger.Typed.Scripts as Scripts -- Low Level Typed Validator - after Vasil it's at Plutus.Script.Utils.V1.Scripts
import           Ledger.Ada           as Ada
import           Playground.Contract  (printJson, printSchemas, ensureKnownCurrencies, stage)
import           Playground.TH        (mkKnownCurrencies, mkSchemaDefinitions)
import           Playground.Types     (KnownCurrency (..))
import           Prelude              (IO, Semigroup (..), String)
import           Text.Printf          (printf)

------------------------------------------------------------ ON-CHAIN ------------------------------------------------------------

{-# INLINABLE mkValidator #-} -- codes that are supposed to run on-chain need this INLINABLE pragma
mkValidator :: () -> Integer -> ScriptContext -> Bool
mkValidator _ r _ = traceIfFalse "wrong redeemer" $ r == 42

data Typed
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = ()
    type instance RedeemerType Typed = Integer

typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed -- tells the compiler that you're using Typed
    $$(PlutusTx.compile [|| mkValidator ||])
    $$(PlutusTx.compile [|| wrap ||])            -- provides the translation into high level typed to level typed
  where
    wrap = Scripts.wrapValidator @() @Integer

validator :: Validator
validator = Scripts.validatorScript typedValidator

valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash typedValidator   -- the hash of the validator

scrAddress :: Ledger.Address
scrAddress = scriptAddress validator

------------------------------------------------------------ OFF-CHAIN ------------------------------------------------------------

type GiftSchema =
            Endpoint "give" Integer
        .\/ Endpoint "grab" Integer

give :: AsContractError e => Integer -> Contract w s e ()
give amount = do
    let tx = mustPayToTheScript () $ Ada.lovelaceValueOf amount  -- This TX needs an output, that is going to the Script Address.
    ledgerTx <- submitTxConstraints typedValidator tx            -- This line submits the TX.
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx            -- This line waits for confirmation.
    logInfo @String $ printf "made a gift of %d lovelace" amount -- This line logs info, usable on the Plutus Playground.

grab :: forall w s e. AsContractError e => Integer -> Contract w s e ()
grab r = do
    utxos <- utxosAt scrAddress            -- This will find all the UTXOs that sit at the script address.
    let orefs   = fst <$> Map.toList utxos -- This gets all the references of the UTXOs.
        lookups = Constraints.unspentOutputs utxos      <>      -- Tells where to find all the UTXOs,
                  Constraints.otherScript validator             -- and inform about the actual validator.
                                                                -- (the spending TX needs to provide the actual validator)
        tx :: TxConstraints Void Void
        tx      = mconcat [mustSpendScriptOutput oref $ Redeemer $ Builtins.mkI r | oref <- orefs] -- Defines the TX giving constrains,
                                                                                                   -- one for each UTXO sitting on this addr.
    ledgerTx <- submitTxConstraintsWith @Void lookups tx -- Allows the wallet to construct the TX with the necesary information. 
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx    -- Waits for confirmation.
    logInfo @String $ "collected gifts"                  -- Logs information.

endpoints :: Contract () GiftSchema Text ()
endpoints = awaitPromise (give' `select` grab') >> endpoints -- Asynchronously waits for the endpoints interactions from the wallet,
  where                                                      -- and recursively waits for the endpoints all over again.
    give' = endpoint @"give" give -- Blocks until "give"
    grab' = endpoint @"grab" grab -- Blocks until "grab"

mkSchemaDefinitions ''GiftSchema  -- Generates the Schema for this contract.

mkKnownCurrencies [] -- Makes known currencies for the playground to have some ADA accessible.
