{ stdenv, fetchFromGitHub, boehmgc, flac, libogg, libvorbis, zlib }:

stdenv.mkDerivation {
  name = "kha";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "kode";
    repo = "kha";
    rev = "907ac4fbc0d073e94ecf1c5cd38a33ade594e8e5";
    sha256 = "0fzykgcz2g0db2ylvxbdwcf1fqsr7ac3x7bnd0dg8054xmkhlpkq";
  };

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out
  '';

  postFixup = stdenv.lib.optionalString (stdenv.system == "i686-linux" || stdenv.system == "x86_64-linux") ''
    # Patch Binaries
    # TODO: Do 32bit bins need specific 32bit libs/interpreter?
    # TODO: Do *-linuxarm binaries need patching as well? How?
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ".:${stdenv.cc.libc}/lib" \
      $out/Kore/Tools/krafix/krafix-linux64
#    patchelf \
#      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#      --set-rpath ".:${stdenv.cc.libc}/lib" \
#      $out/Kore/Tools/krafix/krafix-linux32
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ".:${stdenv.cc.libc}/lib" \
      $out/Kore/Tools/kraffiti/kraffiti-linux64
#    patchelf \
#      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#      --set-rpath ".:${stdenv.cc.libc}/lib" \
#      $out/Kore/Tools/kraffiti/kraffiti-linux32
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ".:${stdenv.cc.libc}/lib:${stdenv.cc.cc.lib}/lib" \
      $out/Tools/kravur/kravur-linux64
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ".:${stdenv.cc.libc}/lib:${zlib}/lib" \
      $out/Tools/haxe/haxe-linux64
#    patchelf \
#      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#      --set-rpath ".:${stdenv.cc.libc}/lib:${zlib}/lib" \
#      $out/Tools/haxe/haxe-linux32
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ".:${stdenv.cc.libc}/lib:${libvorbis}/lib:${libogg}/lib:${flac.out}/lib" \
      $out/Tools/oggenc/oggenc-linux64
#    patchelf \
#      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#      --set-rpath ".:${stdenv.cc.libc}/lib:${libvorbis}/lib:${libogg}/lib:${flac.out}/lib" \
#      $out/Tools/oggenc/oggenc-linux32

    # Patch Shared Objects
    patchelf --set-rpath ".:${stdenv.cc.libc}/lib:${boehmgc}/lib" $out/Backends/Kore/khacpp/project/libs/nekoapi/bin/RPi/libneko.so
    patchelf --set-rpath ".:${stdenv.cc.libc}/lib:${boehmgc}/lib" $out/Backends/Kore/khacpp/project/libs/nekoapi/bin/Linux64/libneko.so
    patchelf --set-rpath ".:${stdenv.cc.libc}/lib:${boehmgc}/lib" $out/Backends/Kore/khacpp/project/libs/nekoapi/bin/Linux/libneko.so

    # Patch library calls that expects nix store files to be mode 644:
    #   A stat is made on srcFile (in the nix store), and its mode used
    #   for destFile, but it expects the mode to be read write, whereas
    #   all regular files in the nix store are made read only.
    #   (33188 is 100644 octal, the required mode)
    substituteInPlace $out/Tools/khamake/node_modules/fs-extra/lib/copy/copy-file-sync.js --replace "stat.mode" "33188"
    substituteInPlace $out/Kore/Tools/koremake/node_modules/fs-extra/lib/copy/copy-file-sync.js --replace "stat.mode" "33188"
  '';

  meta = with stdenv.lib; {
    description = "Modern low level game library and hardware abstraction.";
    homepage = https://kha.tech/;
    downloadPage = https://github.com/Kode/Kha;
    license = licenses.zlib;
    maintainers = [ maintainers.patternspandemic ];
  };
}
