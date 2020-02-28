# our packages overlay
pkgs: _: with pkgs; {
  cardanoDbSyncHaskellPackages = import ./haskell.nix {
    inherit config
      lib
      stdenv
      haskell-nix
      buildPackages
      ;
  };
}
