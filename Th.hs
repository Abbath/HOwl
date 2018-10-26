{-# LANGUAGE TemplateHaskell #-}
module Th where

import Control.Monad
import Language.Haskell.TH

uncurryN :: Int -> Q Exp
uncurryN n = do
  f  <- newName "f"
  xs <- replicateM n (newName "x")
  let args = [VarP f, TupP $ map VarP xs] 
      ntup = map VarE xs
  return $ LamE args $ unwind f $ reverse ntup

unwind f [x] = AppE (VarE f) x
unwind f (x:xs) = let c = unwind f xs in AppE c x

genUncurry :: Int -> Q [Dec]
genUncurry n = (:[]) <$> mkCurryDec n
  where mkCurryDec ith = do
          ucury <- uncurryN ith
          let name = mkName $ "uncurry" ++ show ith
          return $ FunD name [Clause [] (NormalB ucury) []]
