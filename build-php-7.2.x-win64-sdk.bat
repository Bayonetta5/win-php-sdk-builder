@ECHO OFF

REM setting info box
@ECHO ############################################################################
@ECHO ##                                                                        ##
@ECHO ## please install MS Visual Studio Express 2015 for Windows Desktop       ##
@ECHO ## please install MS Visual C++ 2015 Build Tools                          ##
@ECHO ## http://landinghub.visualstudio.com/visual-cpp-build-tools              ##
@ECHO ##                                                                        ##
@ECHO ############################################################################

@ECHO.

REM setting PHP version
SET PHPVERSION=7.2.0RC2
SET PHPMAJOR=%PHPVERSION:~0,3%

REM setting full path of current directory to %DIR&
SET DIR=%~dp0
SET DIR=%Dir:~0,-1%

REM check for .\downloads directory
IF NOT EXIST "%DIR%\downloads" (
    @ECHO.
    @ECHO creating .\downloads directory
    MD %DIR%\downloads
)

REM adding current directory and ./downloads to path
SET PATH=%PATH%;%DIR%;%DIR%\downloads;%DIR%\bin;

REM -----------------------------------------------------------
REM --- CHECK EXTENSIONS TO BUILD
REM -----------------------------------------------------------
@ECHO.
SET /P BUILDEXT_EXCEL=Do you want to build the excel extension? [y/n]

@ECHO.
SET /P BUILDEXT_LZ4=Do you want to build the lz4 extension? [y/n]

REM -----------------------------------------------------------
REM --- TOOLS CHECK
REM -----------------------------------------------------------

REM check for wget availability
wget >nul 2>&1
IF %ERRORLEVEL%==9009 (
    REM since wget is not available look if PHP is available and try to download wget from web with PHP
    php -v >nul 2>&1
    IF NOT %ERRORLEVEL%==9009 (
        REM download wget with php
        @ECHO.
        @ECHO loading wget...
        php -r "file_put_contents('%DIR%\downloads\wget.exe',file_get_contents('https://eternallybored.org/misc/wget/current/wget.exe'));"
    )

    REM if wget download with PHP failed try to download with bitsadmin.exe
    IF NOT EXIST "%DIR%\downloads\wget.exe" (
        REM checking for bitsadmin.exe to download wget.exe from web source
        IF NOT EXIST "%SYSTEMROOT%\System32\bitsadmin.exe" (
            @ECHO.
            @ECHO wget.exe not available
            @ECHO failed to download wget.exe automatically
            @ECHO please download wget from https://eternallybored.org/misc/wget/current/wget.exe
            @ECHO manually and put the wget.exe file in .\downloads folder
            @ECHO it is also available from the php-sdk-binary-tools zip archive
            PAUSE
            EXIT
        )

        REM bitsadmin.exe is available but wget.exe is not - so download it from web
        @ECHO.
        @ECHO loading wget for Windows from...
        @ECHO https://eternallybored.org/misc/wget/current/wget.exe
        bitsadmin.exe /transfer "WgetDownload" "https://eternallybored.org/misc/wget/current/wget.exe" "%DIR%\downloads\wget.exe"
    )

    REM if download of wget failed stop script
    IF NOT EXIST "%DIR%\downloads\wget.exe" (
        @ECHO.
        @ECHO loading wget failed. Please re-run script or
        @ECHO install .\downloads\wget.exe manually
        PAUSE
        EXIT
    )
)

REM check for 7-zip cli tool
7za >nul 2>&1
IF %ERRORLEVEL%==9009 (
    @ECHO.
    @ECHO loading 7-zip cli tool from web...
    wget http://downloads.sourceforge.net/sevenzip/7za920.zip -O %DIR%\downloads\7za920.zip -N

    REM if wget download of 7za failed stop script
    IF NOT EXIST "%DIR%\downloads\7za920.zip" (
        @ECHO.
        @ECHO failed to download 7za920.zip - please re-run this script
        PAUSE
        EXIT
    )

    REM if php is available try unpacking 7za with php
    php -v >nul 2>&1
    IF NOT %ERRORLEVEL%==9009 (
        @ECHO.
        @ECHO unpacking 7za.exe...
        php -r "file_put_contents('%DIR%\downloads\7za.exe',file_get_contents('zip://%DIR%/downloads/7za920.zip#7za.exe'));"
    )

    REM if unpacking 7za with PHP failed try to unpacking with unzip
    IF NOT EXIST "%DIR%\downloads\7za.exe" (
        REM check if unzip.exe is available to unpack 7-zip
        unzip >nul 2>&1
        IF %ERRORLEVEL%==9009 (
            REM check for unzip tool in Git\bin
            IF EXIST "%PROGRAMFILES(X86)%\Git\bin\unzip.exe" (
                @ECHO.
                @ECHO copying unzip.exe from Git...
                COPY "%PROGRAMFILES(X86)%\Git\bin\unzip.exe" "%DIR%\downloads\"
            )

            IF NOT EXIST "%DIR%\downloads\unzip.exe" (
                @ECHO.
                @ECHO please unpack .\downloads\7za920.zip manually and re-run this file
                PAUSE
                EXIT
            )
        )

        REM unpacking 7za920.zip
        @ECHO.
        @ECHO unpacking 7-zip cli tool...
        CD %DIR%\downloads
        unzip -C 7za920.zip 7za.exe
        CD %DIR%
    )
)

7za >nul 2>&1
IF %ERRORLEVEL%==9009 (
    @ECHO.
    @ECHO 7za.exe not found - please re-run this script
    PAUSE
    EXIT
)

REM -----------------------------------------------------------
REM --- PHP SDK PREPARATION
REM -----------------------------------------------------------

IF NOT EXIST "%DIR%\php-sdk-binary-tools" (
    @ECHO.
    @ECHO loading php-sdk-binary tools...
    REM wget http://windows.php.net/downloads/php-sdk/php-sdk-binary-tools-20110915.zip -O %DIR%\downloads\php-sdk-binary-tools-20110915.zip -N
	git clone https://github.com/OSTC/php-sdk-binary-tools.git %DIR%\downloads\php-sdk-binary-tools
	cd %DIR%\downloads\php-sdk-binary-tools
	git checkout php-sdk-2.0.11
	cd %DIR%
	XCOPY %DIR%\downloads\php-sdk-binary-tools\* %DIR%\ /E /Y
)

REM IF NOT EXIST "%DIR%\downloads\php-sdk-binary-tools-20110915.zip" (
    REM @ECHO.
    REM @ECHO php-sdk-binary tools zip file not found in .\downloads please re-run this script
    REM PAUSE
    REM EXIT
REM )

REM @ECHO.
REM @ECHO unpacking php-sdk-binary tools...
REM 7za x %DIR%\downloads\php-sdk-binary-tools-20110915.zip -o%DIR% -y

@ECHO.
@ECHO building directory structure...
MD phpdev
CD phpdev
MD vc15
CD vc15
MD x64
CD x64
MD obj_7.2.0RC2


IF NOT EXIST "%DIR%\downloads\deps-master-vc15-x64.7z" (
    @ECHO.
    @ECHO loading php dependencies...
    wget http://windows.php.net/downloads/php-sdk/deps-master-vc15-x64.7z -O %DIR%\downloads\deps-master-vc15-x64.7z -N
)

IF NOT EXIST "%DIR%\downloads\deps-master-vc15-x64.7z" (
    @ECHO.
    @ECHO php dependencies not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking php dependencies...
7za x %DIR%\downloads\deps-master-vc15-x64.7z -o%DIR%\phpdev\vc15\x64 -y

REM IF NOT EXIST "%SystemRoot%\System32\msvcr110.dll" (
    REM @ECHO.
    REM @ECHO MS visual c redistributable dll not found in system path
    REM @ECHO possible problem for compiling
    REM @ECHO grab an up-2-date version of msvcr110.dll from MS
    REM @ECHO http://www.microsoft.com/en-us/download/details.aspx?id=30679
    REM PAUSE
REM )

REM IF EXIST "%SystemRoot%\System32\msvcr110.dll" (
    REM @ECHO.
    REM @ECHO copying ms visual c redistributable dll from system path...
    REM COPY "%SystemRoot%\System32\msvcr110.dll" "%DIR%\phpdev\vc15\x64\deps\bin\"
REM )

REM IF NOT EXIST "%SystemRoot%\System32\msvcr110d.dll" (
    REM @ECHO.
    REM @ECHO MS visual c redistributable dll not found in system path
    REM @ECHO possible problem for compiling
    REM @ECHO grab an up-2-date version of msvcr110d.dll from MS
    REM @ECHO http://www.microsoft.com/en-us/download/details.aspx?id=30679
    REM PAUSE
REM )

REM IF EXIST "%SystemRoot%\System32\msvcr110d.dll" (
    REM @ECHO.
    REM @ECHO copying ms visual c redistributable dll from system path...
    REM COPY "%SystemRoot%\System32\msvcr110d.dll" "%DIR%\phpdev\vc15\x64\deps\bin\"
REM )

IF NOT EXIST "%DIR%\downloads\php-7.2.0RC2.tar.bz2" (
    @ECHO.
    @ECHO loading php source code...
    REM wget http://de1.php.net/get/php-7.2.0RC2.tar.bz2/from/this/mirror -O %DIR%\downloads\php-7.2.0RC2.tar.bz2 -N
    REM wget https://downloads.php.net/~ab/php-7.2.0RC2.tar.bz2 -O %DIR%\downloads\php-7.2.0RC2.tar.bz2 -N --no-check-certificate
    REM wget http://de1.php.net/get/php-7.2.0RC2.tar.bz2/from/this/mirror -O %DIR%\downloads\php-7.2.0RC2.tar.bz2 -N --no-check-certificate
	wget https://downloads.php.net/~pollita/php-7.2.0RC2.tar.bz2 -O %DIR%\downloads\php-7.2.0RC2.tar.bz2 -N --no-check-certificate
)

IF NOT EXIST "%DIR%\downloads\php-7.2.0RC2.tar.bz2" (
    @ECHO.
    @ECHO php source code not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

IF NOT EXIST "%DIR%\downloads\php-7.2.0RC2.tar" (
    7za x %DIR%\downloads\php-7.2.0RC2.tar.bz2 -o%DIR%\downloads -y
)

IF NOT EXIST "%DIR%\downloads\php-7.2.0RC2.tar" (
    @ECHO.
    @ECHO php source code not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking php source code...
7za x %DIR%\downloads\php-7.2.0RC2.tar -o%DIR%\phpdev\vc15\x64 -y

@REM rename 7.2.0RC2 to 7.2.0RC2
REM MOVE %DIR%\phpdev\vc15\x64\php-7.2.0RC2 %DIR%\phpdev\vc15\x64\php-7.2.0RC2

REM @ECHO cloning php-src repository from github...
REM CD %DIR%\phpdev\vc15\x64
REM git clone --branch=master --depth=1 https://github.com/php/php-src.git php-7.2.0RC2

CD %DIR%

REM SET CFLAGS=--disable-all --enable-cli --enable-snapshot-build --enable-debug --enable-object-out-dir=../obj_7.2.0RC2/ --disable-isapi --disable-nsapi
SET CFLAGS=--disable-all --enable-cli --enable-snapshot-build --enable-object-out-dir=../obj_7.2.0RC2/

REM -----------------------------------------------------------
REM --- PHP_EXCEL / LIBXL EXTENSION
REM -----------------------------------------------------------

IF /I %BUILDEXT_EXCEL%==Y (
    call %DIR%\ext\php_excel_7.2.x_x64.bat
    REM SET CFLAGS=%CFLAGS% --with-excel=shared --with-xml --with-libxml --with-iconv
    SET CFLAGS=%CFLAGS% --with-excel=shared
)

REM -----------------------------------------------------------
REM --- LZ4 EXTENSION
REM -----------------------------------------------------------

IF /I %BUILDEXT_LZ4%==Y (
    call %DIR%\ext\php_lz4_7.2.x_x64.bat
    SET CFLAGS=%CFLAGS% --enable-lz4=shared
)

REM -----------------------------------------------------------
REM --- BUILDING COMPILE.BAT files
REM -----------------------------------------------------------

CD %DIR%

@ECHO @ECHO OFF> compile-php-7.2.0RC2-nts-x64.bat
@ECHO @ECHO ####################################################>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO @ECHO ## Attention                                      ##>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO @ECHO ## please call this batch file with               ##>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO @ECHO ## Visual Studio 2015 Native Tools Command Prompt ##>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO @ECHO ## the standard Windows CLI will not work         ##>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO @ECHO ####################################################>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO.>>compile-php-7.2.0RC2-nts-x64.bat
@ECHO PAUSE>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO call .\bin\phpsdk_setvars.bat>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO CD .\phpdev\vc15\x64\php-7.2.0RC2>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO nmake clean>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO call buildconf.bat --force>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO call configure %CFLAGS% --disable-zts>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO nmake snap /I>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO CD .\..\..\..\..\>> compile-php-7.2.0RC2-nts-x64.bat
@ECHO PAUSE>> compile-php-7.2.0RC2-nts-x64.bat

@ECHO @ECHO OFF> compile-php-7.2.0RC2-ts-x64.bat
@ECHO @ECHO ####################################################>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO @ECHO ## Attention                                      ##>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO @ECHO ## please call this batch file with               ##>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO @ECHO ## Visual Studio 2015 Native Tools Command Prompt ##>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO @ECHO ## the standard Windows CLI will not work         ##>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO @ECHO ####################################################>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO.>>compile-php-7.2.0RC2-ts-x64.bat
@ECHO PAUSE>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO call .\bin\phpsdk_setvars.bat>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO CD .\phpdev\vc15\x64\php-7.2.0RC2>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO nmake clean>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO call buildconf.bat --force>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO call configure %CFLAGS%>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO nmake snap /I>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO CD .\..\..\..\..\>> compile-php-7.2.0RC2-ts-x64.bat
@ECHO PAUSE>> compile-php-7.2.0RC2-ts-x64.bat

PAUSE