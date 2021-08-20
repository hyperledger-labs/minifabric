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
  set minifab_opt=%minifab_opt% -v %CD%/spec.yaml:/home/spec.yaml
) ELSE (
  echo Using default spec file
)

REM inherit proxy environment variables from terminal shell, to support fabric setup onto cloud managed k8s behind proxy
REM   for ansible x k8s ops
set minifab_opt=%minifab_opt% -e K8S_AUTH_PROXY=%K8S_AUTH_PROXY% -e K8S_AUTH_PROXY_HEADERS_PROXY_BASIC_AUTH=%K8S_AUTH_PROXY_HEADERS_PROXY_BASIC_AUTH%
REM   for fabric-tools ops
set minifab_opt=%minifab_opt% -e https_proxy=%https_proxy% -e no_proxy=%no_proxy%

docker run --rm --name minifab -v /var/run/docker.sock:/var/run/docker.sock -v %CD%/vars:/home/vars ^
            -e "ADDRS=!_alladdress!" %minifab_opt% hyperledgerlabs/minifab:latest /home/main.sh %*


endlocal
