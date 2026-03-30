{
  description = "Hermes Agent - Common Lisp rewrite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              sbcl
              rlwrap
              openssl
              git
              curl
            ];

            shellHook = ''
              export PATH="$PWD/bin:$PATH"
              echo "Hermes Common Lisp Development Environment"
              echo "Run './build.sh' to compile the agent."
            '';
          };
        });
    };
}
