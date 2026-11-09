                                           
```
 ::       ▀▀              ▀▀  ██               
 :: ████▄ ██  ██ ██ ████▄ ██ ▀██▀▀ ▄█▀█▄ ▄█▀▀▀ 
 :: ██ ██ ██   ███  ██ ██ ██  ██   ██▄█▀ ▀███▄ 
 :: ██ ██ ██▄ ██ ██ ██ ██ ██▄ ██   ▀█▄▄▄ ▄▄▄█▀ 
```

```sh
# to install on a fresh machine
# run as the target host's user (sudo useradd -m <user>; sudo passwd <user>; su <user>)
nix --extra-experimental-features 'nix-command flakes pipe-operators' \
 run github:thomasgoulet/nixnites#install -- <HOSTNAME> ./nixnites
```

```sh
# packaged editor
nix run github:thomasgoulet/nixnites#helix
```
