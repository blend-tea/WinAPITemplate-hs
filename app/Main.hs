module Main (main) where

import Foreign.C.String (CString, withCString)
import Foreign.C.Types (CInt (..), CLong (..), CUInt (..))
import Foreign.Ptr (Ptr, nullPtr)

-- | @THREADINFOCLASS@ の @ThreadHideFromDebugger@（0x11）。
threadHideFromDebugger :: CUInt
threadHideFromDebugger = 0x11

foreign import ccall unsafe "GetCurrentThread"
  c_GetCurrentThread :: IO (Ptr ())

foreign import ccall unsafe "NtSetInformationThread"
  c_NtSetInformationThread ::
    Ptr () -> CUInt -> Ptr () -> CUInt -> IO CLong

foreign import ccall unsafe "IsDebuggerPresent"
  c_IsDebuggerPresent :: IO CInt

foreign import ccall unsafe "MessageBoxA"
  c_MessageBoxA ::
    Ptr () -> CString -> CString -> CUInt -> IO CInt

-- | 現在スレッドをデバッガから隠す（@ThreadHideFromDebugger@）。
hideCurrentThreadFromDebugger :: IO ()
hideCurrentThreadFromDebugger = do
  th <- c_GetCurrentThread
  _ <-
    c_NtSetInformationThread
      th
      threadHideFromDebugger
      nullPtr
      0
  pure ()

main :: IO ()
main = do
  hideCurrentThreadFromDebugger
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
