@echo off 
echo Welcome to SyncApp_PowerShell! 
echo Caution this is a very basic command line interface, you will have issues with time consuming commands, large data outputs, and combining commands.

:: Start of the loop
:LOOP

:: Clear output.txt before running the new command to prevent leftover data
if exist C:\users\public\output.txt (
    del C:\users\public\output.txt
)

:: Prompt user for input to set the COMMAND variable
set /p COMMAND=SA_PS %CD%^>

:: Check if the user typed 'exit' to break the loop
if /i "%COMMAND%"=="exit" (
    echo Exiting the SA_PS...
    goto :EOF
)

:: Handle 'cd' or 'pushd' commands separately (change the directory)
echo %COMMAND% | findstr /i "^cd " >nul
if not errorlevel 1 (
    rem Extract the directory part from the command (after 'cd')
    for /f "tokens=2*" %%a in ("%COMMAND%") do (
        cd /d %%a
    )
    rem Continue to the next loop iteration
    goto LOOP
)

:: Handle 'set' command to set environment variables directly
echo %COMMAND% | findstr /i "^set " >nul
if not errorlevel 1 (
    rem Run the 'set' command directly in the script
    call %COMMAND%
    rem Continue to the next loop iteration
    goto LOOP
)

:: Handle 'setlocal' and 'endlocal' commands (we don't need to do anything special here in a batch script)
echo %COMMAND% | findstr /i "^setlocal " >nul
if not errorlevel 1 (
    rem 'setlocal' is a batch-specific command, so no need to handle separately
    rem Continue to the next loop iteration
    goto LOOP
)

echo %COMMAND% | findstr /i "^endlocal " >nul
if not errorlevel 1 (
    rem 'endlocal' is a batch-specific command, so no need to handle separately
    rem Continue to the next loop iteration
    goto LOOP
)

:: Handle 'pushd' command (change to directory and push it to the directory stack)
echo %COMMAND% | findstr /i "^pushd " >nul
if not errorlevel 1 (
    rem Extract the directory part from the command (after 'pushd')
    for /f "tokens=2*" %%a in ("%COMMAND%") do (
        pushd %%a
    )
    rem Continue to the next loop iteration
    goto LOOP
)

:: Handle 'popd' command (pop the last directory off the stack and change to it)
echo %COMMAND% | findstr /i "^popd " >nul
if not errorlevel 1 (
    rem Pop the directory off the stack and change to it
    popd
    rem Continue to the next loop iteration
    goto LOOP
)

:: Handle 'Write-Host' or similar commands by simulating output in the batch script
echo %COMMAND% | findstr /i "Write-Host" >nul
if not errorlevel 1 (
    rem Simulate the behavior of Write-Host by displaying the argument in the command prompt
    for /f "tokens=2*" %%a in ("%COMMAND%") do (
        echo %%a
    )
    rem Continue to the next loop iteration
    goto LOOP
)

:: Ensure output.txt is deleted at the start of each command execution
if exist C:\users\public\output.txt (
    del C:\users\public\output.txt
)

:: Run SyncAppvPublishingServer.vbs with the command entered by the user and capture output into a temporary file
C:\Windows\System32\SyncAppvPublishingServer.vbs \"break; %COMMAND% > C:\users\public\output.txt"
echo Running "%COMMAND%" ...

:: Timeout handling for long-running commands (systeminfo, get-childitem, etc.) add in an else if for any long commands you often run.
echo %COMMAND% | findstr /i "^systemi" >nul
if not errorlevel 1 (
    timeout /t 10 >nul
) else (
    echo %COMMAND% | findstr /i "^get-child" >nul
    if not errorlevel 1 (
        timeout /t 30 >nul
    ) else (
        echo %COMMAND% | findstr /i "^adsi" >nul
        if not errorlevel 1 (
            timeout /t 50 >nul
        ) else (
            timeout /t 2 >nul
        )
    )
)

:: After the timeout, check if output.txt exists and display its contents
if exist C:\users\public\output.txt (
    type C:\users\public\output.txt
    del C:\users\public\output.txt
) else (
    echo Command not executed or output file missing!
)

:: Repeat the loop
goto LOOP