@echo off
rem OKOKOK:
adt -package -target native vpwin.exe vpDude.air
:: AIR application packaging
:: More information:
:: http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_5.html#1035959

:: Path to Flex SDK binaries
rem  set PATH=%PATH%;C:\flex_sdk_4.1.0.16076\bin 

:: Signature (see 'CreateCertificate.bat')
set CERTIFICATE=255426024.p12
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERTIFICATE% -storepass 535649
rem -tsa none 

if not exist %CERTIFICATE% goto certificate

:: Output
if not exist air md air
set AIR_FILE=air/vpDudeWin.exe

:: Input
set APP_XML=vpDude-app.xml 
rem set FILE_OR_DIR=-C bin .
set FILE_OR_DIR=-C  .
set SWC=-swc fr.batchass.swc
rem %SWC%
rem adt -package -storetype pkcs12 -keystore E:\Projects\onyx4.3.0\_certThawte\255426024.p12 vpDudeWindows.air vpDude-app.xml

echo Signing AIR setup using certificate %CERTIFICATE%.
echo  adt -package %SIGNING_OPTIONS% -target native %AIR_FILE%  %APP_XML% %FILE_OR_DIR%
call adt -package -storetype pkcs12 -keystore 255426024.p12 vpDudeWin.air vpDude-app.xml fr.batchass.swc
call adt -package %SIGNING_OPTIONS% -target native %AIR_FILE%  %APP_XML% %FILE_OR_DIR%
if errorlevel 1 goto failed

echo.
echo AIR setup created: %AIR_FILE%
echo.
goto end

:certificate
echo Certificate not found: %CERTIFICATE%
echo.
echo Troubleshotting: 
echo A certificate is required, generate one using 'CreateCertificate.bat'
echo.
adt -certificate -cn SelfSigned 1024-RSA %CERTIFICATE% 535649
goto end

:failed
echo AIR setup creation FAILED.

:end
pause