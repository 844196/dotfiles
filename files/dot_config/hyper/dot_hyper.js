"use strict";
// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.
module.exports = {
  config: {
    windowSize: [800, 1200],
    // choose either `'stable'` for receiving highly polished,
    // or `'canary'` for less polished but more frequent updates
    updateChannel: 'stable',
    // default font size in pixels for all tabs
    fontSize: 10,
    // font family with optional fallbacks
    fontFamily: 'JetBrains Mono, JetBrainsMono NF, Source Han Code JP',
    uiFontFamily: 'Cica',
    // default font weight: 'normal' or 'bold'
    fontWeight: 300,
    // font weight for bold characters: 'normal' or 'bold'
    fontWeightBold: 'bold',
    // line height as a relative unit
    lineHeight: 1.5,
    // letter spacing as a relative unit
    letterSpacing: 0.2,
    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    cursorColor: '#C6C8D1',
    // terminal text color under BLOCK cursor
    cursorAccentColor: '#000',
    // `'BEAM'` for |, `'UNDERLINE'` for _, `'BLOCK'` for █
    cursorShape: 'BLOCK',
    // set to `true` (without backticks and without quotes) for blinking cursor
    cursorBlink: false,
    // color of the text
    foregroundColor: '#C6C8D1',
    // terminal background color
    // opacity is only supported on macOS
    backgroundColor: '#161821',
    // terminal selection color
    selectionColor: '#4a548266',
    // border color (window, tabs)
    borderColor: '#333',
    // custom CSS to embed in the main window
    css: `
      .xterm-viewport {
        overflow: hidden !important;
      }

      .header_appTitle {
        display: none !important;
      }

      .header_windowControls * {
        color: #6b7089 !important;
      }
    `,
    // custom CSS to embed in the terminal window
    termCSS: '',
    // set custom startup directory (must be an absolute path)
    workingDirectory: '',
    // if you're using a Linux setup which show native menus, set to false
    // default: `true` on Linux, `true` on Windows, ignored on macOS
    showHamburgerMenu: false,
    // set to `false` (without backticks and without quotes) if you want to hide the minimize, maximize and close buttons
    // additionally, set to `'left'` if you want them on the left, like in Ubuntu
    // default: `true` (without backticks and without quotes) on Windows and Linux, ignored on macOS
    showWindowControls: '',
    // custom padding (CSS format, i.e.: `top right bottom left`)
    padding: '12px 14px',
    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    colors: {
      black: '#1E2132',
      red: '#E27878',
      green: '#B4BE82',
      yellow: '#E2A478',
      blue: '#84A0C6',
      magenta: '#A093C7',
      cyan: '#89B8C2',
      white: '#C6C8D1',
      lightBlack: '#686868',
      lightRed: '#E98989',
      lightGreen: '#C0CA8E',
      lightYellow: '#E9B189',
      lightBlue: '#91ACD1',
      lightMagenta: '#ADA0D3',
      lightCyan: '#95C4CE',
      lightWhite: '#D2D4DE',
      limeGreen: '#C0CA8E',
      lightCoral: '#F08080',
    },
    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    //
    // Windows
    // - Make sure to use a full path if the binary name doesn't work
    // - Remove `--login` in shellArgs
    //
    // Windows Subsystem for Linux (WSL) - previously Bash on Windows
    // - Example: `C:\\Windows\\System32\\wsl.exe`
    //
    // Git-bash on Windows
    // - Example: `C:\\Program Files\\Git\\bin\\bash.exe`
    //
    // PowerShell on Windows
    // - Example: `C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`
    //
    // Cygwin
    // - Example: `C:\\cygwin64\\bin\\bash.exe`
    shell: 'C:\\Windows\\System32\\wsl.exe',
    // for setting shell arguments (i.e. for using interactive shellArgs: `['-i']`)
    // by default `['--login']` will be used
    shellArgs: ['~'],
    // for environment variables
    env: {},
    // Supported Options:
    //  1. 'SOUND' -> Enables the bell as a sound
    //  2. false: turns off the bell
    bell: 'SOUND',
    // An absolute file path to a sound file on the machine.
    // bellSoundURL: '/path/to/sound/file',
    // if `true` (without backticks and without quotes), selected text will automatically be copied to the clipboard
    copyOnSelect: false,
    // if `true` (without backticks and without quotes), hyper will be set as the default protocol client for SSH
    defaultSSHApp: true,
    // if `true` (without backticks and without quotes), on right click selected text will be copied or pasted if no
    // selection is present (`true` by default on Windows and disables the context menu feature)
    quickEdit: false,
    // choose either `'vertical'`, if you want the column mode when Option key is hold during selection (Default)
    // or `'force'`, if you want to force selection regardless of whether the terminal is in mouse events mode
    // (inside tmux or vim with mouse mode enabled for example).
    macOptionSelectionMode: 'vertical',
    // Whether to use the WebGL renderer. Set it to false to use canvas-based
    // rendering (slower, but supports transparent backgrounds)
    webGLRenderer: true,
    // keypress required for weblink activation: [ctrl|alt|meta|shift]
    // todo: does not pick up config changes automatically, need to restart terminal :/
    webLinksActivationKey: '',
    // if `false` (without backticks and without quotes), Hyper will use ligatures provided by some fonts
    disableLigatures: false,
    // set to true to disable auto updates
    disableAutoUpdates: false,
    // set to true to enable screen reading apps (like NVDA) to read the contents of the terminal
    screenReaderMode: false,
    // for advanced config flags please refer to https://hyper.is/#cfg
  },
  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hyperpower`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: [],
  // in development, you can create a directory under
  // `~/.hyper_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: [],
  keymaps: {
    // Example
    // 'window:devtools': 'cmd+alt+o',
  },
};
//# sourceMappingURL=config-default.js.map
