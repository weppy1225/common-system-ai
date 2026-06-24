@echo off
setlocal
rem === 이 배치가 있는 허브 디렉토리 (= common-system-ai), %~dp0 은 끝에 \ 포함 ===
set "HUB=%~dp0"
if "%HUB:~-1%"=="\" set "HUB=%HUB:~0,-1%"

rem === 워크스페이스 = 허브의 부모 폴더 (예: workspace-common-system / workspace-kyochon-oms) ===
for %%I in ("%HUB%\..") do set "WS=%%~fI"
for %%I in ("%WS%") do set "WSNAME=%%~nxI"

rem === 프로젝트명 = 워크스페이스 폴더명에서 "workspace-" 접두어 제거 ===
set "PROJECT=%WSNAME:workspace-=%"

rem === 형제 BE/FE 레포 (= {프로젝트}-be / {프로젝트}-fe) ===
set "BE=%WS%\%PROJECT%-be"
set "FE=%WS%\%PROJECT%-fe"

wt --title "%PROJECT% (AI)" --tabColor "#22bbf2" -d "%HUB%" cmd /k "claude --dangerously-skip-permissions --add-dir %USERPROFILE%\Pictures\Screenshots %BE% %FE%"
