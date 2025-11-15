let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  rust-overlay = (import (builtins.fetchGit {
    url = "https://github.com/oxalica/rust-overlay";
    ref = "master";
    rev = "08c33e87c4829bbdd42b5af247cf7a19e126369f";
  }));
  pkgs = import nixpkgs { config = {}; overlays = [ rust-overlay ]; };
  system = builtins.currentSystem;
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "master";
      rev = "c8261cd60b0623635b4b88ae0f75ac3bfeddf260";
    })).extensions.${system};
  extensionsList = with extensions.vscode-marketplace; [
      rust-lang.rust-analyzer
      wgsl-analyzer.wgsl-analyzer
      tamasfe.even-better-toml
      usernamehw.errorlens
      fill-labs.dependi
      #vadimcn.vscode-lldb
      splo.vscode-bevy-inspector
      nefrob.vscode-just-syntax
      ms-vscode.hexeditor
  ];
  buildInputs = with pkgs; [
    udev
    alsa-lib
    libglvnd
    vulkan-loader
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    libxkbcommon
    wayland
    lldb
    typos
    taplo
    clang
    lld
  ];
  buildInputsLdPath = pkgs.lib.makeLibraryPath buildInputs;
in
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      pkg-config
    ];
    inherit buildInputs;
    packages = with pkgs; [
      git
      (rust-bin.stable.latest.default.override {
        extensions = ["rust-src" "clippy"];
        targets = [
          "x86_64-unknown-none"
          "wasm32-unknown-unknown"  
        ];
      })
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = extensionsList;
      })
      just
    ];
    LD_LIBRARY_PATH = "${buildInputsLdPath}";
    LLDB_DEBUGSERVER_PATH = "${pkgs.lldb}/bin/lldb-server";
    NIXOS_OZONE_WL=1;
  }
