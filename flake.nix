{
  description = "configuration for nixos";

  outputs =
    { self, ... }:
    let
      # inputs are pinned by .tack/pins.lock.json and resolved here
      tack = import ./.tack { };

      inputs = tack // { inherit self; };

      # import-tree matches paths relative to ./nix (i.e. `/features/docker.nix`).
      # the equivalent glob looks like `nix/{*,{features,hosts,users,themes}/*}.nix`
      moduleFiles = ''/((features|hosts|users|themes)/)?[^/]+\.nix'';
    in
    tack.flake-parts.lib.mkFlake
      {
        inherit inputs;
        self = self // { inherit inputs; };
      }
      {
        imports = [
          tack.den.flakeModule
          (tack.import-tree.match moduleFiles ./nix)
        ];
      };
}
