{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "kore";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "kode";
    repo = "kore";
    rev = "16b38a5c5dd74f28604608eac89e106a8015a2f0";
    sha256 = "1syd5zbmdzv904v26147x3vza6lj55apvrknnqjgd9gp7h55zli6";
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
      $out/Tools/kraffiti/kraffiti-linux64
#    patchelf \
#      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#      --set-rpath ".:${stdenv.cc.libc}/lib" \
#      $out/Tools/kraffiti/kraffiti-linux32
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ".:${stdenv.cc.libc}/lib" \
      $out/Tools/krafix/krafix-linux64
#    patchelf \
#      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#      --set-rpath ".:${stdenv.cc.libc}/lib" \
#      $out/Tools/krafix/krafix-linux32
    
    # Patch library calls that expects nix store files to be mode 644:
    #   A stat is made on srcFile (in the nix store), and its mode used
    #   for destFile, but it expects the mode to be read write, whereas
    #   all regular files in the nix store are made read only.
    #   (33188 is 100644 octal, the required mode)
    substituteInPlace $out/Tools/koremake/node_modules/fs-extra/lib/copy/copy-file-sync.js --replace "stat.mode" "33188"
  '';

  meta = with stdenv.lib; {
    description = "Modern low level game library and hardware abstraction.";
    homepage = https://kode.tech/;
    downloadPage = https://github.com/Kode/Kore;
    license = licenses.zlib;
    maintainers = [ maintainers.patternspandemic ];
  };
}
