@echo off
setlocal
rem === Hub directory that holds this batch (= common-system-ai). %~dp0 ends with a backslash ===
set "HUB=%~dp0"
if "%HUB:~-1%"=="\" set "HUB=%HUB:~0,-1%"

rem === Workspace = parent folder of the hub (e.g. workspace-common-system / workspace-kyochon-oms) ===
for %%I in ("%HUB%\..") do set "WS=%%~fI"
for %%I in ("%WS%") do set "WSNAME=%%~nxI"

rem === Project name = workspace folder name minus the "workspace-" prefix ===
set "PROJECT=%WSNAME:workspace-=%"

rem === Sibling BE/FE repos (= {project}-be / {project}-fe) ===
set "BE=%WS%\%PROJECT%-be"
set "FE=%WS%\%PROJECT%-fe"

wt --title "%PROJECT% (AI)" --tabColor "#22bbf2" -d "%HUB%" cmd /k "cd /d %HUB% && claude --dangerously-skip-permissions --add-dir %USERPROFILE%\Pictures\Screenshots %BE% %FE%"
