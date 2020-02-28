############################################################################
# Builds Haskell packages with Haskell.nix
############################################################################
{ lib
, stdenv
, haskell-nix
, buildPackages
, config ? {}
# GHC attribute name
, compiler ? config.haskellNix.compiler or "ghc865"
# Enable profiling
, profiling ? config.haskellNix.profiling or false
}:
let

  # This creates the Haskell package set.
  # https://input-output-hk.github.io/haskell.nix/user-guide/projects/
  pkgSet = haskell-nix.cabalProject {
    src = haskell-nix.haskellLib.cleanGit { src = ../.; };
    ghc = buildPackages.haskell-nix.compiler.${compiler};
    modules = [
      # Add source filtering to local packages
      {
        packages.cardano-db-sync.src = haskell-nix.haskellLib.cleanGit
          { src = ../.; subDir = "cardano-sync-db"; };
        packages.cardano-db-sync-extneded.src = haskell-nix.haskellLib.cleanGit
          { src = ../.; subDir = "cardano-db-sync-extended"; };
      }
      {
        # Packages we wish to ignore version bounds of.
        # This is similar to jailbreakCabal, however it
        # does not require any messing with cabal files.
        packages.katip.doExactConfig = true;

        # split data output for ekg to reduce closure size
        packages.ekg.components.library.enableSeparateDataOutput = true;
        packages.cardano-db-sync.configureFlags = [ "--ghc-option=-Wall" "--ghc-option=-Werror" ];
        packages.cardano-db-sync-extended.configureFlags = [ "--ghc-option=-Wall" "--ghc-option=-Werror" ];
        enableLibraryProfiling = profiling;
      }
    ];
    pkg-def-extras = [
      # Workaround for https://github.com/input-output-hk/haskell.nix/issues/214
      (hackage: {
        packages = {
          "hsc2hs" = (((hackage.hsc2hs)."0.68.4").revisions).default;
        };
      })
    ];
  };
in
  pkgSet
