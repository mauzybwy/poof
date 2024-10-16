{
  description = "Developer environment shell for streamline";

  inputs = {
    nixpkgs = {
      owner = "NixOS";
      repo = "nixpkgs";
      type = "github";
      # 24.05
      rev = "772b1ca1162faa1d19d51c1047eadf657ab629e5";
    };
  };

  outputs = { self, nixpkgs }:
    let
      # Helper to provide system-specific attributes
      forAllSupportedSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in

    {
      devShells = forAllSupportedSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = [
            pkgs.docker
            pkgs.git
            pkgs.gnumake
            pkgs.nixpkgs-fmt
            pkgs.nodejs
            pkgs.nodePackages.pnpm
            pkgs.postgresql_15
            pkgs.ruby_3_3
          ];
        };
      });
    };
}
