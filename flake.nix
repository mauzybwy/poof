{
  description = "Developer environment shell for poof";

  inputs = {
    nixpkgs = {
      owner = "NixOS";
      repo = "nixpkgs";
      type = "github";
      # 24.11
      rev = "5051ae6744b993fcfab221e8bd38f8bc26f88393";
    };
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # Helper to provide system-specific attributes
    forAllSupportedSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
          lib = nixpkgs.lib;
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
      pkgs,
      lib,
    }: let
      elixir = pkgs.beam.packages.erlang_27.elixir_1_18;
      nodejs = pkgs.nodejs_22;
    in {
      default = pkgs.mkShell {
        # enable IEx shell history
        ERL_AFLAGS = "-kernel shell_history enabled";
        packages =
          [
            elixir
            nodejs
            pkgs.go-task
            pkgs.postgresql_17
            pkgs.nixpkgs-fmt
            pkgs.elixir-ls
            pkgs.flyctl
          ]
          ++ lib.optional pkgs.stdenv.isLinux pkgs.inotify-tools
          ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [CoreServices]);

        shellHook = ''
          echo
          echo "--- Welcome to ${name} ${test} ---"
          export PATH=${bin}:$PATH
          export MIX_HOME="$PWD/.cache/mix"
          export HEX_HOME="$PWD/.cache/hex"
          export DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres

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
