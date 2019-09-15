let
  pkgs = import <nixpkgs> {};
in

with pkgs;

stdenv.mkDerivation {
  name = "foxit";

  version = "0.1";

  src = fetchurl {
    url = "http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz";
    name = "foxit.tar.gz";
    sha256 = "144v4jyclhi4qjpxdc1ip22m02ys272qd6001bkzg1nzxka9nmvb";
  };

  # src = ~/Downloads/FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz;

  # $ ldd ./FoxitReader.enu.setup.2.4.4.0911\(r057d814\).x64.run
  # linux-vdso.so.1 (0x00007ffc727fc000)
  # libutil.so.1 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib/libutil.so.1 (0x00007f0da7a7f000)
  # libX11.so.6 => not found
  # libX11-xcb.so.1 => not found
  # libxcb.so.1 => not found
  # libfontconfig.so.1 => not found
  # libfreetype.so.6 => not found
  # libdbus-1.so.3 => not found
  # libdl.so.2 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib/libdl.so.2 (0x00007f0da7a78000)
  # librt.so.1 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib/librt.so.1 (0x00007f0da7a6e000)
  # libpthread.so.0 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib/libpthread.so.0 (0x00007f0da7a4d000)
  # libstdc++.so.6 => not found
  # libm.so.6 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib/libm.so.6 (0x00007f0da78b7000)
  # libgcc_s.so.1 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib/libgcc_s.so.1 (0x00007f0da769f000)
  # libc.so.6 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib/libc.so.6 (0x00007f0da74e9000)
  # /lib64/ld-linux-x86-64.so.2 => /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27/lib64/ld-linux-x86-64.so.2 (0x00007f0da7a8

  libPath = stdenv.lib.makeLibraryPath [
    xorg.libX11
    # xorg.libX11-xcb
    xorg.libxcb
    freetype
    fontconfig
    dbus.lib
    gcc.cc # libstdc++
    glib
    zlib
  ];

  buildCommand = ''
    cat << EOF

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "$libPath"

    EOF

    mkdir -p $out/bin
    cd $out/bin
    tar xzvf $src
    mv "$out/bin/FoxitReader.enu.setup.2.4.4.0911(r057d814).x64.run" $out/bin/Foxit.run
    chmod +x $out/bin/Foxit.run
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "$libPath" $out/bin/Foxit.run
  '';
}
