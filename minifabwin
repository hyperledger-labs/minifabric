@echo off
setlocal
setlocal enabledelayedexpansion

SET _alladdress=
for /f "usebackq tokens=2 delims=:" %%a in (`ipconfig ^| findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"`) do (
  set _temp=%%a
  rem remove leading space
  set _ipaddress=!_temp:~1!
  set _bad=0
  if [!_ipaddress:~-2!]==[.0] set _bad=1
  if [!_ipaddress:~-2!]==[.1] set _bad=1
  if [!_bad!]==[0] (
    if [!_alladdress!]==[] (
      set _alladdress=!_ipaddress!
    ) else (
      set _alladdress=!_alladdress!,!_ipaddress!
    )
  )
)
IF EXIST "%CD%/spec.yaml" (
  echo Using spec file: %CD%\spec.yaml
  docker run --rm --name minifab -v /var/run/docker.sock:/var/run/docker.sock -v %CD%/vars:/home/vars ^
    -v %CD%/spec.yaml:/home/spec.yaml -e "ADDRS=!_alladdress!" hyperledgerlabs/minifab:latest /home/main.sh %*
) ELSE (
  echo Using default spec file
  docker run --rm --name minifab -v /var/run/docker.sock:/var/run/docker.sock -v %CD%/vars:/home/vars ^
    -e "ADDRS=!_alladdress!" hyperledgerlabs/minifab:latest /home/main.sh %*
)

endlocal
