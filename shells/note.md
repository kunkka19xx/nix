## Nix shell

Nix-shell for a specific purpose, after running something, you remove it.
Or you can not do it normally by declaration, or it's just complicated.

Refer: [nix-shell](https://nix.dev/manual/nix/2.22/command-ref/nix-shell) 

### Command

```shell
nix-shell <path-to-shell.nix>
```

### List

1. [loadtest](./python-lt.nix)
- for my locust testing, this requires `stdenv.cc.cc.lib`  as a dependency

### Clean

All pkgs in the nix/store/...
-> run this to claim space as usual:

```shell
nix-collect-garbage -d
``` 
