#!/bin/bash

cd ~/plutus-apps
nix-shell --command "cd plutus-playground-client; plutus-playground-generate-purs; npm start"

