@echo off

rem 参照
rem http://tldp.org/LDP/abs/html/dosbatch.html
rem https://qiita.com/sta/items/8cab80fe74b8dcfa5336
rem https://stackoverflow.com/questions/2768608/batch-equivalent-of-bash-backticks
rem https://nurs.hatenablog.com/entry/20101110/1289396618

setlocal

set ip=169.254.100.102
set mibpath=/usr/share/snmp/mibs

pushd "%~dp0"

for /f "usebackq tokens=*" %%a in (`snmpget -v 2c -M %mibpath% -m +WIENER-CRATE-MIB -c public %ip% sysMainSwitch.0`) do (set status=%%a)

if "%status%"=="WIENER-CRATE-MIB::sysMainSwitch.0 = INTEGER: off(0)" (
    call :abort The MPOD crate main switch is OFF!
) else (
    echo "Measured channel voltages at sense line:"
    snmpwalk -Cp -Oqv -v 2c -M %mibpath% -m +WIENER-CRATE-MIB -c public %ip% outputMeasurementSenseVoltage
    echo.
    echo "Measured channel currents:"
    snmpwalk -Cp -Oqv -v 2c -M %mibpath% -m +WIENER-CRATE-MIB -c public %ip% outputMeasurementCurrent    
)

popd

pause


rem ----------
rem subrootins
rem ----------

:abort
echo (%selfname%) Error!: %*
exit /b
