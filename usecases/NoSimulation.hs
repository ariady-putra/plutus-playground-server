{-# LANGUAGE NumericUnderscores #-}

module NoSimulation where

import Playground.Types (Simulation (Simulation))
import Playground.Types (KnownCurrency)
import Playground.Types (simulationActions)
import Playground.Types (simulationId)
import Playground.Types (simulationName)
import Playground.Types (simulationWallets)

import SimulationUtils (simulatorWallet)

import Wallet.Emulator.Types (WalletNumber (..))

sim :: [KnownCurrency] -> [Simulation]
sim regKnownCurrencies =
    [ Simulation
        { simulationName = "Simulation 1"
        , simulationId = 1
        , simulationWallets = simulatorWallet regKnownCurrencies 100_000_000 <$> map WalletNumber [1,2]
        , simulationActions = []
        }
    ]
