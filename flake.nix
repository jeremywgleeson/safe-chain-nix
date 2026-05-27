{
  description = "Nix package and Home Manager integration for Aikido Safe Chain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };

      testHome =
        system: module:
        let
          pkgs = pkgsFor system;
        in
        (home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.homeModules.default
            module
            {
              home.enableNixpkgsReleaseCheck = false;
              home = {
                username = "safe-chain-test";
                homeDirectory =
                  if pkgs.stdenv.hostPlatform.isDarwin then "/Users/safe-chain-test" else "/home/safe-chain-test";
                stateVersion = "24.11";
              };
            }
          ];
        }).activationPackage;
    in
    {
      overlays.default = final: _prev: {
        safe-chain = final.callPackage ./pkgs/safe-chain { };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.safe-chain;
          safe-chain = pkgs.safe-chain;
        }
      );

      homeModules.default = import ./modules/home-manager/safe-chain.nix;
      homeModules.safe-chain = self.homeModules.default;

      checks = forAllSystems (system: {
        package = self.packages.${system}.safe-chain;

        home-cli = testHome system {
          programs.safe-chain.enable = true;
        };

        home-wrappers = testHome system {
          programs.safe-chain = {
            enable = true;
            integrationMode = "wrappers";
            wrapPython = true;
          };
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              jq
              nodejs_24
              nixfmt
            ];
          };
        }
      );
    };
}
