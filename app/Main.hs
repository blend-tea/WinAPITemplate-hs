module Main (main) where

import Foreign.C.String (CString, withCString)
import Foreign.C.Types (CInt (..), CUInt (..))
import Foreign.Ptr (Ptr, nullPtr)

foreign import ccall unsafe "IsDebuggerPresent"
  c_IsDebuggerPresent :: IO CInt

foreign import ccall unsafe "MessageBoxA"
  c_MessageBoxA ::
    Ptr () -> CString -> CString -> CUInt -> IO CInt

main :: IO ()
main = do
  r <- c_IsDebuggerPresent
  let dbg = r /= 0
  let (title, body) =
        if dbg
          then ("Debug Check", "A debugger is attached.")
          else ("Hello", "Hello, World!")
  withCString body $ \bodyPtr ->
    withCString title $ \titlePtr -> do
      _ <- c_MessageBoxA nullPtr bodyPtr titlePtr 0
      pure ()
