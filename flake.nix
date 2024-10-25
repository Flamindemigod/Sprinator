{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pname = "sprinator";
        pkgs = nixpkgs.legacyPackages.${system};
        nativeBuildInputs = with pkgs; [
          zig
          zls
          glibc
        ];
        buildInputs = with pkgs; [raylib];
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          name = pname;
          inherit nativeBuildInputs buildInputs;
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = pname;
          src = ./.;

          XDG_CACHE_HOME = "${placeholder "out"}";
          inherit buildInputs;
          nativeBuildInputs = nativeBuildInputs ++ [pkgs.zig.hook];
        };
      });
}

