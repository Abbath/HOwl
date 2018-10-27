{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}

import qualified Data.Aeson as A
import qualified Data.ByteString.Lazy as BS

data Task = Task 
  { taskArguments :: [A.Value]
  , taskExpected :: A.Value
  } deriving Generic

deriveJSON defaultOptions{fieldLabelModifier = drop 4, constructorTagModifier = map toLower} ''Task

class Foo a where
  run :: [Value] -> a -> BS.ByteString

instance {-# OVERLAPPABLE #-} ToJSON a => Foo a where
  run [] a = fromJust $ encode a
  run _ _ = error "!"

instance {-# OVERLAPPING #-} (FromJSON a, Foo b) => Foo (a -> b) where
  run (s:ss) f = fromJust . encode $ run ss (f (fromJust $ decode s))
  run _ _ = error "!!"

main :: IO ()
main = do
    s <- getContents
    mapM_ unmagic $ lines s

unmagic :: String -> IO ()
unmagic s = print . fromJust . decode $ BS.pack s

-- test1, test2 :: String
-- test1 = run ["1","2.3"] $ \(i::Int) (j::Double) -> fromIntegral i + j  
-- test2 = run ["[1,2]","2"] $ \(i::[Int]) (j::Int) -> take j i