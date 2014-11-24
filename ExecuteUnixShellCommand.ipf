#pragma rtGlobals=1		// Use modern global access method.

Function/S ExecuteUnixShellCommand(uCommand, printCommandInHistory, printResultInHistory)
        String uCommand                         // Unix command to execute
        Variable printCommandInHistory
        Variable printResultInHistory

        if (printCommandInHistory)
                printf "Unix command: %s\r", uCommand
        endif

        String cmd
        sprintf cmd, "do shell script \"%s\"", uCommand
        ExecuteScriptText cmd

        if (printResultInHistory)
                Print S_value
        endif

        return S_value
End
