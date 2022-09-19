# plutus-playground-server
Plutus Playground Server with an additional tab for [Dead-man's Switch (ariady-putra/morbid: Davy Jones' Locker)](https://github.com/ariady-putra/morbid).
<img src="https://github.com/ariady-putra/plutus-playground-server/blob/main/screenshots/0_DeadManSwitch.png"/>

Updated for [week 6](https://github.com/input-output-hk/plutus-pioneer-program/blob/main/code/week06/cabal.project#L45) of Plutus Pioneer Program.
[`plutus-playground-start-client.sh`](plutus-playground-start-client.sh#L4):
```nix-shell
cd plutus-playground-client
plutus-playground-generate-purs
npm start
```
Added `plutus-playground-generate-purs` to regenerate PureScript Code, which is needed as per Plutus Playground Client [README.md](https://github.com/input-output-hk/plutus-apps/blob/main/plutus-playground-client/README.md#generating-purescript-code).

## simulations
<img src="https://github.com/ariady-putra/plutus-playground-server/blob/main/screenshots/1_DavyJonesLocker.png"/>
<img src="https://github.com/ariady-putra/plutus-playground-server/blob/main/screenshots/2_DuplicateChest.png"/>
<img src="https://github.com/ariady-putra/plutus-playground-server/blob/main/screenshots/3_NoChestToPostpone.png"/>
<img src="https://github.com/ariady-putra/plutus-playground-server/blob/main/screenshots/4_WrongPassword.png"/>
<img src="https://github.com/ariady-putra/plutus-playground-server/blob/main/screenshots/5_NoChestToUnlock.png"/>
<img src="https://github.com/ariady-putra/plutus-playground-server/blob/main/screenshots/6_UnlockTooSoon.png"/>
