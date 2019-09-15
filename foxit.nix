let
  pkgs = import <nixpkgs> {};
in

with pkgs;

let
  # $ patchelf --print-needed ./FoxitReader
  # libQt5WebKitWidgets.so.5
  # libQt5PrintSupport.so.5
  # libQt5WebKit.so.5
  # libQt5Widgets.so.5
  # libQt5Xml.so.5
  # libQt5Network.so.5
  # libQt5Sql.so.5
  # libQt5Gui.so.5
  # libQt5Core.so.5
  # libGL.so.1
  # libpthread.so.0
  # libstdc++.so.6
  # libm.so.6
  # libgcc_s.so.1
  # libc.so.6
  # librt.so.1

  ldLibraryPath = with pkgs; stdenv.lib.makeLibraryPath  [
    libffi
    qt5.qtbase
    zlib
    xlibs.libX11
    xlibs.libXrender
    xorg_sys_opengl
    xorg.libX11
    xorg.libxcb
    freetype
    fontconfig
    dbus.lib
    gcc.cc # libstdc++
    glib

    libGL
    qt5.qtwebkit
  ];
in

# https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/qt-5/hooks/wrap-qt-apps-hook.sh
stdenv.mkDerivation {
  name = "FoxitReader";

  version = "0.1";

  src = /home/srghma/opt_/foxitsoftware/foxitreader;

  unpackPhase = ":"; # https://github.com/NixOS/nixpkgs/issues/65434#issuecomment-515669809
  dontUnpack = true;

  buildInputs = with pkgs; [ rsync ];

  installPhase = ''
    mkdir -p $out
    rsync -r $src/ $out/
    ls -al $out
    chmod +xw $out/FoxitReader
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${ldLibraryPath}" $out/FoxitReader
  '';
}
