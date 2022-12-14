{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module Playground.Usecases where

import Data.ByteString (ByteString)
import Data.FileEmbed (embedFile, makeRelativeToProject)
import Data.Text qualified as T
import Data.Text.Encoding qualified as T
import Language.Haskell.Interpreter (SourceCode (SourceCode))

marker :: T.Text
marker = "TRIM TO HERE\n"

strip :: T.Text -> T.Text
strip text = snd $ T.breakOnEnd marker text

process :: ByteString -> SourceCode
process = SourceCode . strip . T.decodeUtf8

vesting :: SourceCode
vesting = process $(makeRelativeToProject "usecases/Vesting.hs" >>= embedFile)

game :: SourceCode
game = process $(makeRelativeToProject "usecases/Game.hs" >>= embedFile)

morbid :: SourceCode
morbid = process $(makeRelativeToProject "usecases/Morbid.hs" >>= embedFile)

typed :: SourceCode
typed = process $(makeRelativeToProject "usecases/Week02/Typed.hs" >>= embedFile)

signed :: SourceCode
signed = process $(makeRelativeToProject "usecases/Week05/Signed.hs" >>= embedFile)

errorHandling :: SourceCode
errorHandling =
    process $(makeRelativeToProject "usecases/ErrorHandling.hs" >>= embedFile)

crowdFunding :: SourceCode
crowdFunding =
    process $(makeRelativeToProject "usecases/Crowdfunding.hs" >>= embedFile)

starter :: SourceCode
starter = process $(makeRelativeToProject "usecases/Starter.hs" >>= embedFile)

helloWorld :: SourceCode
helloWorld = process $(makeRelativeToProject "usecases/HelloWorld.hs" >>= embedFile)
