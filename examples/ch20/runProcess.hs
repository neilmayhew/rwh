{-# OPTIONS_GHC -fglasgow-exts #-}
import System.Process
import Control.Concurrent
import System.IO
import System.Exit

type SysCommand = (String, [String])
type HsCommand = String -> IO String

data CommandResult = CommandResult {
    cmdOutput :: String,
    getExitCode :: IO ExitCode}

class CommandLike a where
    invoke :: a -> String -> IO CommandResult

instance CommandLike SysCommand where
    invoke (cmd, args) input =
        do (newinp, newout, newerr, ph) <-
                runInteractiveProcess cmd args Nothing Nothing
           forkIO $ hPutStr newinp input
           forkIO $ copy newerr stderr
           c <- hGetContents newout
           return $ CommandResult c (waitForProcess ph)

instance CommandLike HsCommand where
    invoke func input =
        do result <- func input 
           return $ CommandResult result (return ExitSuccess)

data (CommandLike src, CommandLike dest) => 
     PipeCommand src dest = PipeCommand src dest 

instance (CommandLike a, CommandLike b) =>
         CommandLike (PipeCommand a b) where
    invoke (PipeCommand src dest) input =
        do res1 <- invoke src input
           res2 <- invoke dest (cmdOutput res1)
           return $ CommandResult (cmdOutput res2) (getEC res1 res2)

(-|-) :: (CommandLike a, CommandLike b) => a -> b -> PipeCommand a b
(-|-) = PipeCommand

{-
instance (CommandLike a, CommandLike b) => 
         Pipeable a b Handles where
    (-|-) srcCmd destCmd =
        do src <- invoke srcCmd
           dest <- invoke destCmd
           forkIO (copy (out src) (inp dest))
           forkIO (copy (err src) stdout)
           return $ Handles {inp = (inp src),
                             out = (out dest),
                             err = (err dest),
                             getExitCode = getEC src dest}

instance (CommandLike a) => HSCommand a Handles where
    (-|-) hsfunc destCmd =
        do dest <- invoke destCmd

-}
copy :: Handle -> Handle -> IO ()
copy src dest =
    do c <- hGetContents src
       hPutStr dest c

getEC :: CommandResult -> CommandResult -> IO ExitCode
getEC src dest =
    do sec <- getExitCode src
       dec <- getExitCode dest
       case sec of
            ExitSuccess -> return dec
            x -> return x

