#!/bin/bash

cd ~/plutus-apps
nix-shell --command "cd plutus-playground-server; plutus-playground-server"

