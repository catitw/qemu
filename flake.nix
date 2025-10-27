{
  description = "QEMU development environment (devShell)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          # https://github.com/go-delve/delve/issues/3085#issuecomment-1419664637
          hardeningDisable = [ "fortify" ];

          nativeBuildInputs = with pkgs; [
            git
            pkg-config
            meson
            ninja
            python3
            git
            ccache
            cmake
            flex
            bison
            isa-l
            rust-bindgen
            bear
            # NOTE: `clang-tools` first, then `clang`.
            # see [#308482](https://github.com/NixOS/nixpkgs/issues/308482#issuecomment-2090095873)
            clang-tools # clangd / clang-format
            clang
          ];

          # https://wiki.qemu.org/Hosts/Linux
          buildInputs = with pkgs; [
            bashInteractive

            gcc
            libgcrypt
            numactl
            # sdl2-compat
            # gtk3
            # vte
            capstone
            glib
            dtc
            pixman
            zlib
            libaio
            xen
          ];

          CCACHE_DIR = "${toString ./.ccache}";
          CCACHE_COMPRESS = "1";
          LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";

          # NOTE: configure with `./configure  --target-list=x86_64-softmmu --enable-debug --enable-rust`
          shellHook = ''
            # fix tmux/zellij bash prompt breaks
            # see: https://discourse.nixosstag.fcio.net/t/tmux-bash-prompt-breaks-inside-of-flakes/60925/8
            export SHELL=${pkgs.lib.getExe pkgs.bash}

            echo "welcome to QEMU devshell"
          '';
        };
      }
    );
}
