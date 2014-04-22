@ECHO OFF

REM setting info box
@ECHO ############################################################################
@ECHO ##                                                                        ##
@ECHO ## please install MS Visual Studio Express 2012 for Windows Desktop       ##
@ECHO ## http://www.microsoft.com/en-us/download/details.aspx?id=34673          ##
@ECHO ##                                                                        ##
@ECHO ############################################################################

@ECHO.

REM setting PHP version
SET PHPVERSION=5.5.11
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

REM check for wget availability
wget >nul 2>&1
IF %ERRORLEVEL%==9009 (
    REM since wget is not available look if PHP is available and try to download wget from web with PHP
    php -v >nul 2>&1
    IF NOT %ERRORLEVEL%==9009 (
        REM download wget with php
        @ECHO.
        @ECHO loading wget...
        php -r "file_put_contents('%DIR%\downloads\wget.exe',file_get_contents('http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe'));"
    )
    
    REM if wget download with PHP failed try to download with bitsadmin.exe
    IF NOT EXIST "%DIR%\downloads\wget.exe" (
        REM checking for bitsadmin.exe to download wget.exe from web source
        IF NOT EXIST "%SYSTEMROOT%\System32\bitsadmin.exe" (
            @ECHO.
            @ECHO wget.exe not available
            @ECHO failed to download wget.exe automatically
            @ECHO please download wget from http://eternallybored.org/misc/wget/wget.exe or 
            @ECHO http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe manually
            @ECHO and put the wget.exe file in .\downloads folder
            @ECHO it is also available from the php-sdk-binary-tools zip archive
            PAUSE
            EXIT
        )
        
        REM bitsadmin.exe is available but wget.exe is not - so download it from web
        @ECHO.
        @ECHO loading wget for Windows from...
        @ECHO http://eternallybored.org/misc/wget/wget.exe
        REM @ECHO http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
        bitsadmin.exe /transfer "WgetDownload" "http://eternallybored.org/misc/wget/wget.exe" "%DIR%\downloads\wget.exe"
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

IF NOT EXIST "%DIR%\downloads\7za.exe" (
    @ECHO.
    @ECHO .\downloads\7za.exe not found - please re-run this script
    PAUSE
    EXIT
)

IF NOT EXIST "%DIR%\downloads\php-sdk-binary-tools-20110915.zip" (
    @ECHO.
    @ECHO loading php-sdk-binary tools...
    wget http://windows.php.net/downloads/php-sdk/php-sdk-binary-tools-20110915.zip -O %DIR%\downloads\php-sdk-binary-tools-20110915.zip -N
)

IF NOT EXIST "%DIR%\downloads\php-sdk-binary-tools-20110915.zip" (
    @ECHO.
    @ECHO php-sdk-binary tools zip file not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking php-sdk-binary tools...
7za x %DIR%\downloads\php-sdk-binary-tools-20110915.zip -o%DIR% -y

@ECHO.
@ECHO building directory structure...
MD phpdev
CD phpdev
MD vc11
CD vc11
MD x86
CD x86
MD obj_5.5.11

IF NOT EXIST "%SystemRoot%\SysWOW64\msvcr110.dll" (
    @ECHO.
    @ECHO MS visual c redistributable dll not found in system path
    @ECHO possible problem for compiling
    @ECHO grab an up-2-date version of msvcr110.dll from MS
    @ECHO http://www.microsoft.com/en-us/download/details.aspx?id=30679
    PAUSE
)

IF EXIST "%SystemRoot%\SysWOW64\msvcr110.dll" (
    @ECHO.
    @ECHO copying ms visual c redistributable dll from system path...
    COPY %SystemRoot%\SysWOW64\msvcr110.dll %DIR%\phpdev\vc11\x86\deps\bin\
)

IF NOT EXIST "%DIR%\downloads\deps-5.5-vc11-x86.7z" (
    @ECHO.
    @ECHO loading php dependencies...
    wget http://windows.php.net/downloads/php-sdk/deps-5.5-vc11-x86.7z -O %DIR%\downloads\deps-5.5-vc11-x86.7z -N
)

IF NOT EXIST "%DIR%\downloads\deps-5.5-vc11-x86.7z" (
    @ECHO.
    @ECHO php dependencies not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking php dependencies...
7za x %DIR%\downloads\deps-5.5-vc11-x86.7z -o%DIR%\phpdev\vc11\x86 -y

IF NOT EXIST "%DIR%\downloads\php-5.5.11.tar.bz2" (
    @ECHO.
    @ECHO loading php source code...
    wget http://de1.php.net/get/php-5.5.11.tar.bz2/from/this/mirror -O %DIR%\downloads\php-5.5.11.tar.bz2 -N
)

IF NOT EXIST "%DIR%\downloads\php-5.5.11.tar.bz2" (
    @ECHO.
    @ECHO php source code not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

IF NOT EXIST "%DIR%\downloads\php-5.5.11.tar" (
    7za x %DIR%\downloads\php-5.5.11.tar.bz2 -o%DIR%\downloads -y
)

IF NOT EXIST "%DIR%\downloads\php-5.5.11.tar" (
    @ECHO.
    @ECHO php source code not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking php source code...
7za x %DIR%\downloads\php-5.5.11.tar -o%DIR%\phpdev\vc11\x86 -y

REM @ECHO cloning php-src repository from github...
REM git clone -b "PHP-5.5.11" https://github.com/php/php-src.git php-5.5.11

CD %DIR%

REM -----------------------------------------------------------
REM --- PHP_EXCEL / LIBXL EXTENSION
REM -----------------------------------------------------------

CD %DIR%\phpdev\vc11\x86\php-5.5.11\ext

@ECHO.
@ECHO cloning php_excel repository...
git clone https://github.com/iliaal/php_excel.git
CD %DIR%\phpdev\vc11\x86\php-5.5.11\ext\php_excel

IF NOT EXIST "%DIR%\downloads\libxl-win-3.5.4.zip" (
    @ECHO.
    @ECHO loading libxl library for php_excel...
    wget ftp://xlware.com/libxl-win-3.5.4.zip -O %DIR%\downloads\libxl-win-3.5.4.zip -N
)

IF NOT EXIST "%DIR%\downloads\libxl-win-3.5.4.zip" (
    @ECHO.
    @ECHO libxl lib not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking libxl library...
7za x %DIR%\downloads\libxl-win-3.5.4.zip -o%DIR%\phpdev\vc11\x86\php-5.5.11\ext\php_excel -y
CD %DIR%\phpdev\vc11\x86\php-5.5.11\ext\php_excel
RENAME libxl-3.5.4.1 libxl

@ECHO.
@ECHO rearranging local libxl files for php-src integration...
XCOPY .\libxl\include_c\* .\libxl\ /E
XCOPY .\libxl\bin\* .\libxl\ /E

@ECHO.
@ECHO copying local libxl to php deps folder...
XCOPY .\libxl\bin\* %DIR%\phpdev\vc11\x86\deps\bin\ /E
XCOPY .\libxl\lib\* %DIR%\phpdev\vc11\x86\deps\lib\ /E
XCOPY .\libxl\include_c\libxl.h %DIR%\phpdev\vc11\x86\deps\include\ /E
MD %DIR%\phpdev\vc11\x86\deps\include\libxl
XCOPY .\libxl\* %DIR%\phpdev\vc11\x86\deps\include\libxl\ /E

CD %DIR%

REM -----------------------------------------------------------
REM --- LZ4 EXTENSION
REM -----------------------------------------------------------

CD %DIR%\phpdev\vc11\x86\php-5.5.11\ext

@ECHO.
@ECHO cloning lz4 repository...
git clone https://github.com/kjdev/php-ext-lz4.git
CD %DIR%\phpdev\vc11\x86\php-5.5.11\ext\php-ext-lz4\lz4

@ECHO.
@ECHO updating lz4 c files from original source
wget https://lz4.googlecode.com/svn/trunk/lz4.c -N --no-check-certificate
wget https://lz4.googlecode.com/svn/trunk/lz4.h -N --no-check-certificate
wget https://lz4.googlecode.com/svn/trunk/lz4hc.c -N --no-check-certificate
wget https://lz4.googlecode.com/svn/trunk/lz4hc.h -N --no-check-certificate
wget https://lz4.googlecode.com/svn/trunk/programs/xxhash.c -N --no-check-certificate
wget https://lz4.googlecode.com/svn/trunk/programs/xxhash.h -N --no-check-certificate

CD %DIR%

REM -----------------------------------------------------------
REM --- BUILDING COMPILE.BAT files
REM -----------------------------------------------------------

CD %DIR%

@ECHO @ECHO OFF> compile-php-5.5.11-nts-x32.bat
@ECHO @ECHO ####################################################>> compile-php-5.5.11-nts-x32.bat
@ECHO @ECHO ## Attention                                      ##>> compile-php-5.5.11-nts-x32.bat
@ECHO @ECHO ## please call this batch file with               ##>> compile-php-5.5.11-nts-x32.bat
@ECHO @ECHO ## Visual Studio 2012 Native Tools Command Prompt ##>> compile-php-5.5.11-nts-x32.bat
@ECHO @ECHO ## the standard Windows cli will not work         ##>> compile-php-5.5.11-nts-x32.bat
@ECHO @ECHO ####################################################>> compile-php-5.5.11-nts-x32.bat
@ECHO.>>compile-php-5.5.11-nts-x32.bat
@ECHO call .\bin\phpsdk_setvars.bat>> compile-php-5.5.11-nts-x32.bat
@ECHO CD .\phpdev\vc11\x86\php-5.5.11>> compile-php-5.5.11-nts-x32.bat
@ECHO nmake clean>> compile-php-5.5.11-nts-x32.bat
@ECHO call buildconf.bat>> compile-php-5.5.11-nts-x32.bat
@ECHO call configure --disable-all --enable-cli --with-excel=shared --enable-lz4=shared --enable-snapshot-build --enable-debug-pack --enable-object-out-dir=../obj_5.5.11/ --enable-static-analyze --disable-isapi --disable-nsapi --disable-zts>> compile-php-5.5.11-nts-x32.bat
@ECHO nmake snap>> compile-php-5.5.11-nts-x32.bat
@ECHO CD .\..\..\..\..\>> compile-php-5.5.11-nts-x32.bat
@ECHO PAUSE>> compile-php-5.5.11-nts-x32.bat

@ECHO @ECHO OFF> compile-php-5.5.11-ts-x32.bat
@ECHO @ECHO ####################################################>> compile-php-5.5.11-ts-x32.bat
@ECHO @ECHO ## Attention                                      ##>> compile-php-5.5.11-ts-x32.bat
@ECHO @ECHO ## please call this batch file with               ##>> compile-php-5.5.11-ts-x32.bat
@ECHO @ECHO ## Visual Studio 2012 Native Tools Command Prompt ##>> compile-php-5.5.11-ts-x32.bat
@ECHO @ECHO ## the standard Windows cli will not work         ##>> compile-php-5.5.11-ts-x32.bat
@ECHO @ECHO ####################################################>> compile-php-5.5.11-ts-x32.bat
@ECHO.>>compile-php-5.5.11-ts-x32.bat
@ECHO call .\bin\phpsdk_setvars.bat>> compile-php-5.5.11-ts-x32.bat
@ECHO CD .\phpdev\vc11\x86\php-5.5.11>> compile-php-5.5.11-ts-x32.bat
@ECHO nmake clean>> compile-php-5.5.11-ts-x32.bat
@ECHO call buildconf.bat>> compile-php-5.5.11-ts-x32.bat
@ECHO call configure --disable-all --enable-cli --with-excel=shared --enable-lz4=shared --enable-snapshot-build --enable-debug-pack --enable-object-out-dir=../obj_5.5.11/ --enable-static-analyze --disable-isapi --disable-nsapi>> compile-php-5.5.11-ts-x32.bat
@ECHO nmake snap>> compile-php-5.5.11-ts-x32.bat
@ECHO CD .\..\..\..\..\>> compile-php-5.5.11-ts-x32.bat
@ECHO PAUSE>> compile-php-5.5.11-ts-x32.bat

PAUSE