{-# LANGUAGE OverloadedStrings #-}

import           Prelude

import           Test.Tasty (defaultMain, testGroup)

import qualified Test.IO.Cardano.Db.Insert
import qualified Test.IO.Cardano.Db.Migration
import qualified Test.IO.Cardano.Db.TotalSupply
import qualified Test.IO.Cardano.Db.Rollback

import           System.Environment (lookupEnv, setEnv)
import           System.Directory (getCurrentDirectory)
import           System.FilePath ((</>))

main :: IO ()
main = do
  _ <- provideDefaultPgPassFile

  defaultMain $
    testGroup "Database"
      [ Test.IO.Cardano.Db.Migration.tests
      , Test.IO.Cardano.Db.Insert.tests
      , Test.IO.Cardano.Db.TotalSupply.tests
      , Test.IO.Cardano.Db.Rollback.tests
      ]


-- |If the env is not set, set it to default.
provideDefaultPgPassFile :: IO String
provideDefaultPgPassFile = do
  maybePgPassFile <- lookupEnv "PGPASSFILE"
  whenNothing maybePgPassFile $ do
      currentDir <- getCurrentDirectory
      let pgPassFile = currentDir </> "../config/pgpass"
      setEnv "PGPASSFILE" pgPassFile
      return pgPassFile
  where
    whenNothing :: Monad m => Maybe a -> m a -> m a
    whenNothing (Just x) _ = pure x
    whenNothing Nothing  m = m


