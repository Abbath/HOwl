{-# LANGUAGE OverloadedStrings, TemplateHaskell #-}
import Solution
import qualified Data.Aeson as A
import Data.Maybe
import Data.Map (Map)
import qualified Data.HashMap.Lazy as H
import qualified Data.Text as T
import qualified Data.ByteString.Lazy.Char8 as BS  
import Control.Arrow ((***))
-- import Th (genUncurry)
import Data.Tuple.Curry

data Result = Ok | Failure | Error deriving Show

main :: IO ()
main = do
    s <- getContents
    mapM_ unmagic $ lines s

unmagic :: String -> IO ()
unmagic s = print . apply . unmagic2 . unhashmap . unobject $ (fromJust $ A.decode (BS.pack s) :: A.Value)

unobject :: A.Value -> H.HashMap T.Text A.Value
unobject (A.Object a) = a
unobject _ = error "Incorrect data!"

unhashmap :: H.HashMap T.Text A.Value -> (BS.ByteString, BS.ByteString)
unhashmap hm = (A.encode $ hm H.! "arguments", A.encode $ hm H.! "expected")

unmagic2 :: (BS.ByteString, BS.ByteString) -> Maybe ((Double, Map String Int, [String]), [[String]])
unmagic2 bb = let (a,b) = (A.decode *** A.decode) bb
              in case (a,b) of
                (_, Nothing) -> Nothing
                (Nothing, _) -> Nothing
                (Just x, Just y) -> Just (x,y)

apply :: Maybe ((Double, Map String Int, [String]), [[String]]) -> Result 
apply (Just (a, b)) = if uncurryN solution a == b then Ok else Failure
apply Nothing = Error