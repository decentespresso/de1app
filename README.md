# DE1 Tablet App

The `misc` submodule containes scripts and androwish / undroidwish support files.
The `psd` submodule contains the original photoshop files from which the skins and settings pages are generated.

The de1beta folder should ideally be copyable directly to the tablet and run from there. Further testing might be required to test some of the so far unreleased skins.

## Development

### Installation

> The following steps assume you are using MacOS

Install tcl/tk
```
brew install tcl-tk
```

Install undroidwish
1. Download MacOS dmg from: http://www.androwish.org/download/index.html
2. Click the downloaded dmg to install
3. Drag `undroidwish` application from the mounted dmg into `Applications` folder
4. Add `undroidwish` to your path: `sudo ln -s /Applications/undroidwish.app/Contents/MacOS/undroidwish /usr/local/bin/.`

### Running

In the `de1plus` folder there is a shell file: `unde1plus.sh` simply run this in the terminal to start the application:

```
./de1plus/unde1plus.sh
```