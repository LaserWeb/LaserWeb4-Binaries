#!/bin/sh
#
# build.sh
#
# Builds OSX distribution of LaserWeb
#

# Set target branch
export TARGET_UI_BRANCH=$(cat BRANCH)
echo "Targetting UI Branch: $TARGET_UI_BRANCH"

# Commence
cd ../

# Download LaserWeb UI / install modules
if [ ! -d "LaserWeb4" ]; then
  git clone https://github.com/Laserweb/LaserWeb4.git
  cd LaserWeb4
  git checkout $TARGET_UI_BRANCH
  yarn
  npm run installdev
else
  echo "LaserWeb4 folder exists, skip download.."
  cd LaserWeb4
fi

# Override files
#echo "Applying file overrides.."
#cp -frv ../LaserWeb/overrides/LaserWeb4.1 ../

# Bundle LaserWeb app using webpack
npm run bundle-dev
cd ../

# Download LaserWeb server component / install modules
if [ ! -d "lw.comm-server" ]; then
  git clone https://github.com/Laserweb/lw.comm-server.git
  cd lw.comm-server
  git checkout "electron_bundler"
  yarn
else
  echo "skip git clone lw.comm-server.."
  cd lw.comm-server
  echo "cleaning out ./dist folder.."
  rm -rf dist
fi

# Copy web front-end + build server component
./node_modules/.bin/electron-rebuild
npm run copy
./node_modules/.bin/build -p never

# Find release file
find -f dist/**/*.dmg
