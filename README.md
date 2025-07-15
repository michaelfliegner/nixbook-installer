## Instructions for creating the image

1. Clone this repo
2. cd into the folder
3. Run ```nix build .#packages.x86_64-linux.install-iso --extra-experimental-features flakes --extra-experimental-features nix-command```
4. The ISO file will be in ```/result/iso/```
