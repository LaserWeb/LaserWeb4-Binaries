::
:: build.win.bat
::
:: Builds Windows PC distribution of LaserWeb
::

:: Set UnicodeData.txt path to work around https://github.com/dodo/node-unicodetable/issues/16
set NODE_UNICODETABLE_UNICODEDATA_TXT=%CD%\UnicodeData\UnicodeData.txt
set LW_DIR=Laserweb4 

:: Set target branch
set /p TARGET_UI_BRANCH=<BRANCH
echo "Targetting UI Branch: %TARGET_UI_BRANCH%"

:: Commence
cd ..
dir

:: Download LaserWeb UI / install modules
IF NOT EXIST %LW_DIR% (
    git clone https://github.com/Laserweb/LaserWeb4.git %LW_DIR%
    cd %LW_DIR%
    git checkout %TARGET_UI_BRANCH%
    CALL yarn
    CALL npm run installdev
) ELSE (
    echo "LaserWeb4 folder exists, skip download.."
    cd %LW_DIR%
)

:: Override files
::echo "Applying file overrides.."
::xcopy /s /f /y ..\LaserWeb\overrides\LaserWeb4 .

:: Save Git log to Env variable
git log --pretty=format:"[%%h](https://github.com/Laserweb/LaserWeb4/commit/%%H)%%x09%%an%%x09%%ad%%x09%%s" --date=short -10 > git.log.output
set /p GIT_LOGS=<git.log.output

git describe --abbrev=0 --tags > ui_version.output
set /p UI_VERSION=<ui_version.output
set /p SERVER_VERSION_FULL=<node_modules\lw.comm-server\version.txt
set SERVER_VERSION = %SERVER_VERSION_FULL:~-3%

:: Bundle LaserWeb app using webpack
CALL npm run bundle-dev
:: Copy web front-end
cd %CD%
git tag -f %UI_VERSION%-%$SERVER_VERSION%
xcopy ..\%LW_DIR%\dist .\app

.\node_modules\.bin\electron-rebuild
.\node_modules\.bin\build --em.version=%UI_VERSION%-%$SERVER_VERSION% -p never

:: Move release file to distribution directory
xcopy dist\*.exe ..\LaserWeb4-Binaries\dist\
cd  ..\LaserWeb4-Binaries\dist\
dir
cd ..
