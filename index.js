
const config=require('lw.comm-server/config.js');
require('lw.comm-server');


// Electron app
const electron = require('electron');
const autoUpdater = require("electron-updater").autoUpdater
      autoUpdater.checkForUpdatesAndNotify();
      
// Module to control application life.
const electronApp = electron.app;
// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
var mainWindow = null;

const shouldQuit = electronApp.makeSingleInstance((commandLine, workingDirectory) => {
  // Someone tried to run a second instance, we should focus our window.
  if (mainWindow) {
    if (mainWindow.isMinimized()) mainWindow.restore();
    mainWindow.focus();
  }
});

if (shouldQuit) {
  electronApp.quit();
}

// Create myWindow, load the rest of the app, etc...
if (electronApp) {
    // Module to create native browser window.
    const BrowserWindow = electron.BrowserWindow;

    function createWindow() {
        // Create the browser window.
        mainWindow = new BrowserWindow({width: 1200, height: 900, fullscreen: false, center: true, resizable: true, title: "LaserWeb", frame: true, autoHideMenuBar: true, icon: '/public/favicon.png' });

        // and load the index.html of the app.
        mainWindow.loadURL('http://127.0.0.1:' + config.webPort);

        // Emitted when the window is closed.
        mainWindow.on('closed', function () {
            // Dereference the window object, usually you would store windows
            // in an array if your app supports multi windows, this is the time
            // when you should delete the corresponding element.
            mainWindow = null;
        });
        mainWindow.once('ready-to-show', () => {
          mainWindow.show()
        })
        mainWindow.maximize()
        //mainWindow.webContents.openDevTools() // Enable when testing
    };

    electronApp.commandLine.appendSwitch("--ignore-gpu-blacklist");
    electronApp.commandLine.appendSwitch("--disable-http-cache");
    // This method will be called when Electron has finished
    // initialization and is ready to create browser windows.
    // Some APIs can only be used after this event occurs.


    electronApp.on('ready', createWindow);

    // Quit when all windows are closed.
    electronApp.on('window-all-closed', function () {
        // On OS X it is common for applications and their menu bar
        // to stay active until the user quits explicitly with Cmd + Q
        if (process.platform !== 'darwin') {
            electronApp.quit();
        }
    });

    electronApp.on('activate', function () {
        // On OS X it's common to re-create a window in the app when the
        // dock icon is clicked and there are no other windows open.
        if (mainWindow === null) {
            createWindow();
        }
    });
}