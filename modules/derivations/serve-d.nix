{ 
    stdenv, 
    lib, 
    fetchFromGitHub, 
    fetchpatch, 
    dmd, 
    dub, 
    curl, 
    gnumake 
}:

stdenv.mkDerivation rec {
  pname = "serve-d";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "Pure-D";
    repo = "serve-d";
    rev = "v${version}";
    sha256 = "sha256-BDwTJkxtr1BLhOpnlag2BtAIzH/3+mmUydi82TIfDHM=";
    name = "serve-d";
  };

  nativeBuildInputs = [ dmd dub gnumake ];
  buildInputs = [ curl ];

#   makeCmd = ''
#     make -f posix.mak all DMD_DIR=dmd DMD=${ldc.out}/bin/ldmd2 CC=${stdenv.cc}/bin/cc
#   '';

  buildPhase = ''
    ${dub.out}/bin/dub build
  '';

#   doCheck = true;

#   checkPhase = ''
#       $makeCmd test_rdmd
#     '';

  installPhase = ''
    mkdir -p $out/bin
    cp serve-d $out/bin/serve-d
  '';

  meta = with lib; {
    description = "Serve D";
    homepage = "https://github.com/dlang/tools";
    license = lib.licenses.mit;
    maintainers = with maintainers; [  ];
    platforms = lib.platforms.unix;
  };
}
