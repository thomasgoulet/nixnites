{
  description = "configuration for nixos";

  inputs = {

    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/26.05";

    # os & home
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # den
    den.url = "github:denful/den";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    # others
    niri.url = "github:sodiboo/niri-flake";
    nu-mcp = {
      url = "github:ck3mp3r/nu-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, den, ... }:
    let
      # import-tree matches paths relative to ./nix (i.e. `/features/docker.nix`).
      # the equivalent glob looks like `nix/{*,{features,hosts,users}/*}.nix`
      moduleFiles = ''/((features|hosts|users)/)?[^/]+\.nix'';
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        den.flakeModule
        (inputs.import-tree.match moduleFiles ./nix)
      ];
    };
}
