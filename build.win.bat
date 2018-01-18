::
:: build.win.bat
::
:: Builds Windows PC distribution of LaserWeb
::

:: Set UnicodeData.txt path to work around https://github.com/dodo/node-unicodetable/issues/16
set NODE_UNICODETABLE_UNICODEDATA_TXT=%CD%\UnicodeData\UnicodeData.txt

:: Set target branch
set /p TARGET_UI_BRANCH=<BRANCH
echo "Targetting UI Branch: %TARGET_UI_BRANCH%"

:: Commence
cd ..
dir

:: Download LaserWeb UI / install modules
IF NOT EXIST "LaserWeb4" (
    git clone https://github.com/Laserweb/LaserWeb4.git
    cd LaserWeb4
    git checkout %TARGET_UI_BRANCH%
    CALL yarn
    CALL npm run installdev
) ELSE (
    echo "LaserWeb4 folder exists, skip download.."
    cd LaserWeb4
)

:: Override files
::echo "Applying file overrides.."
::xcopy /s /f /y ..\LaserWeb\overrides\LaserWeb4 .

:: Save Git log to Env variable
git log --pretty=format:"[%%h](https://github.com/Laserweb/LaserWeb4/commit/%%H)%%x09%%an%%x09%%ad%%x09%%s" --date=short -10 > git.log.output
set /p GIT_LOGS=<git.log.output

:: Bundle LaserWeb app using webpack
CALL npm run bundle-dev
cd ..

:: Download LaserWeb server component / install modules
IF NOT EXIST "lw.comm-server" (
    git clone https://github.com/Laserweb/lw.comm-server.git
    cd lw.comm-server
    git checkout "electron_bundler"
    CALL yarn
) ELSE (
    echo "lw.comm-server folder exists, skip download.."
    cd lw.comm-server
)

:: Copy web front-end + build server component
CALL npm run dist

:: Move release file to distribution directory
xcopy dist\*.exe ..\laserweb\dist\
cd ..\laserweb\dist
dir
cd ..
