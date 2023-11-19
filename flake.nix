# References:
# https://blog.lenny.ninja/part-1-quickly-packaging-services-using-nix-flakes.html
# https://ayats.org/blog/no-flake-utils/
# https://nixos.org/manual/nixos/stable/#sec-writing-modules
# https://nixos.org/manual/nixpkgs/stable/#ssec-language-go
{
  description = "A tool to automatically generate a NixOS config from a Docker Compose project.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = system: nixpkgs.legacyPackages.${system};
    pname = "compose2nix";
    owner = "aksiksi";
    # LINT.OnChange(version)
    version = "0.1.5";
    # LINT.ThenChange(main.go:version, README.md:version)
  in {
    # Nix package
    packages = forAllSystems (system:
      let pkgs = pkgsFor system; in {
        # TODO(aksiksi): Pull from GitHub.
        default = pkgs.buildGoModule {
          inherit pname;
          inherit version;
          src = ./.;
          vendorSha256 = "sha256-9D6qmTs2aw6oAQdHbmlWV2JnkIyBjKSd8XfW+rRJVM0=";
        };
      }
    );

    # Development shell
    devShells = forAllSystems (system:
      let pkgs = pkgsFor system; in {
        default = pkgs.mkShell {
          buildInputs = [ pkgs.go pkgs.gopls ];
        };
        shell = pkgs.mkShell {
          buildInputs = [ self.packages.${system}.default ];
        };
      }
    );

    # Run:
    # nix build .#checks.x86_64-linux.integrationTest
    # To run interactively:
    # nix build .#checks.x86_64-linux.integrationTest.driverInteractive
    # See: https://nixos.org/manual/nixos/stable/index.html#sec-running-nixos-tests-interactively
    checks.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      # This test is meant to be run by nixos-test/test.sh.
      # https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
      # https://nix.dev/tutorials/nixos/integration-testing-using-virtual-machines
      integrationTest = pkgs.nixosTest (import ./nixos-test/test.nix);
    };
  };
}
