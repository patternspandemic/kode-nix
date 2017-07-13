self: super:
{
  kha = super.callPackage ./pkgs/kha { };
  # For now, the following Kha bins/libs are used as packaged,
  # and patched as needed.
  #khacpp
  #haxe
  #khamake
  #kravur
  #oggenc
  
  kore = super.callPackage ./pkgs/kore { };
  # For now, the following Kore bins/libs are used as packaged,
  # and patched as needed.
  #koremake
  #kraffiti
  #krafix

  libkorec = super.callPackage /home/pattern/repos/KoreC { };

  #krom = super.callPackage ./pkgs/krom { };
  #v8
  
  #kodestudio
}
