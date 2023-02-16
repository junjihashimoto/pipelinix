{ mkDerivation, aeson, base, bytestring, lib, text, yaml }:
mkDerivation {
  pname = "yaml2pipeline";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ aeson base bytestring text yaml ];
  license = lib.licenses.bsd3;
}
