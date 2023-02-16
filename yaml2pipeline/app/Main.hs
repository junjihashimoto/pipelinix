#! /usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2c1f2cc193dba77639132f817a27b1067ecd8267.tar.gz
#! nix-shell -p "pkgs.haskell.packages.ghc922.ghcWithPackages (p: with p; [aeson text bytestring yaml])"
#! nix-shell -i "runhaskell"

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}


import GHC.Generics
import Data.Aeson
import Data.Text
import qualified Data.Yaml as Y
import qualified Data.ByteString.Lazy as B
import qualified Data.Text.IO as T
import Prelude hiding (product)
import Control.Monad (forM_)
import qualified Data.HashMap.Strict as M

data Process = Process
  { compose :: Maybe [Text]
  , command :: Maybe Text
  , parameters :: Maybe [Text]
  } deriving (Generic,Show)

instance FromJSON Process

data Pipeline = Pipeline (M.HashMap Text Process)
  deriving (Generic,Show)

instance FromJSON Pipeline

main = do
    mm <- Y.decodeFileEither "pipeline.yaml"
    case mm of
      Right (Pipeline v) -> do
        T.putStrLn $ "{pkgs ? import <nixpkgs> {}"
        T.putStrLn $ ",lib ? (import (builtins.fetchTarball https://github.com/junjihashimoto/pipelinix/archive/2e04642a7230de1999fd1d8b4d0c31cd2b9534d4.tar.gz)).lib}:"
        T.putStrLn $ "lib.pipeline pkgs (self: {"
        
        forM_ (M.toList v) $ \(key,process) -> do
          case compose process of
            Just v -> do
              T.putStrLn $ "  " <> key <> " = lib.compose ["
              forM_ v $ \drv -> do
                T.putStrLn $ "    " <> drv
              T.putStrLn $ "  ];"
            Nothing -> return ()
            
          case (parameters process, command process) of
            (Just params, Just cmd) -> do
              T.putStr $ "  " <> key <> " = "
              forM_ params $ \input -> do
                T.putStr $ input <> ": "
              T.putStrLn $ "''"
              T.putStr $ "    " <> cmd
              T.putStrLn $ "  '';"
            (Nothing, Just cmd) -> do
              T.putStr $ "  " <> key <> " = "
              T.putStrLn $ "''"
              T.putStr $ "    " <> cmd
              T.putStrLn $ "  '';"
            _ -> return ()
          T.putStrLn ""

        T.putStrLn $ "})"
      Left err -> print err
