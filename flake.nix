{
  description = "Developer environment shell for poof";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    nixpkgs-25_05.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    nixpkgs-unstable-2025_11_22 = {
      owner = "NixOS";
      repo = "nixpkgs";
      type = "github";
      # unstable as of 2025-11-22
      rev = "050e09e091117c3d7328c7b2b7b577492c43c134";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-25_05,
    nixpkgs-unstable-2025_11_22,
  }: let
    # Helper to provide system-specific attributes
    forAllSupportedSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          lib = nixpkgs.lib;
          pkgs = import nixpkgs {inherit system;};
          pkgs-25_05 = import nixpkgs-25_05 {inherit system;};
          pkgs-unstable-2025_11_22 = import nixpkgs-unstable-2025_11_22 {inherit system;};
        });

    supportedSystems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    test = ":)";
    name = "Poof";
    pwd = "$PWD";
    bin = "${pwd}/bin";
  in {
    devShells = forAllSupportedSystems ({
      lib,
      pkgs,
      pkgs-25_05,
      pkgs-unstable-2025_11_22,
    }: let
      elixir = pkgs-unstable-2025_11_22.beam28Packages.elixir_1_19;
      elixir-ls = pkgs-unstable-2025_11_22.beam28Packages.elixir-ls;
      livebook = pkgs-unstable-2025_11_22.beam28Packages.livebook;
      nodejs = pkgs.nodejs_22;
      postgresql = pkgs-unstable-2025_11_22.postgresql_18;
    in {
      default = pkgs.mkShell.override {
        stdenv = pkgs.stdenvNoCC;
      } {
        # enable IEx shell history
        ERL_AFLAGS = "-kernel shell_history enabled";
        packages =
          [
            # Overrides
            elixir
            elixir-ls
            nodejs
            livebook
            postgresql

            # Standard
            pkgs.nixpkgs-fmt
            pkgs.go-task
          ];

        shellHook = ''
          echo
          echo "--- Welcome to ${name} ${test} ---"
          export PATH=${bin}:$PATH
          export MIX_HOME="$PWD/.cache/mix"
          export HEX_HOME="$PWD/.cache/hex"

          source ./scripts/postgres_setup.sh

          echo "[$PWD]"
          echo "Elixir: ${elixir}"
          echo "MIX_HOME=$MIX_HOME"
          echo "HEX_HOME=$HEX_HOME"
          echo "DATABASE_URL=$DATABASE_URL"
          echo
        '';
      };
    });
  };
}
