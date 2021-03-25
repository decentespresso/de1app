# DE1 App Plugin (Extension) Development Overview

This overview aims to provide an introduction to getting started with plugin (extension) development. It gives some background on how plugins and the plugin system works and gives some pointers to getting started with plugin development. While this document is a starting point, it does not aim to cover Tcl or how the rest of the DE1 application is architected. See [DE1 App Core: Shot Cycle Overview](de1_app_core_shot_cycle_overview.md) for more details on the operations of the DE1 tablet application.

## Glossary

- [Tcl (Tool Command Language)](https://www.tcl.tk/) - "Tcl (Tool Command Language) is a very powerful but easy to learn dynamic programming language, suitable for a very wide range of uses, including web and desktop applications, networking, administration, testing and many more." It is the main programming language used by the DE1 App and its extensions. It enables cross-platform development via a dynamic programming language with simple shell applications for different platforms.
- [Tk](https://www.tcl.tk/) - "Tk is a graphical user interface toolkit that takes developing desktop applications to a higher level than conventional approaches. Tk is the standard GUI not only for Tcl, but for many other dynamic languages, and can produce rich, native applications that run unchanged across Windows, Mac OS X, Linux and more."
- [AndroWish](https://www.androwish.org/) - "AndroWish allows to run desktop Tcl and Tk programs almost unaltered on the Android Platform while it opens the door to script a rich feature set of a mobile platform."
- [undroidwish](https://www.androwish.org/home/wiki?name=undroidwish) - "undroidwish uses the same code base [as AndroWish] and offers a similar feature set on various desktop and embedded platforms."

## Set up your development environment

- Install Tcl/Tk if you do not have it already. You can verify by doing a `which tclsh`. Many operating systems already come with a distribution of Tcl/Tk installed. Read more [here](https://www.tcl.tk/software/tcltk/) if you need to install it.
- Install undroidwish
  - See the [Downloads page for AndroWish](https://www.androwish.org/download/index.html). Download the appropriate `undroidwish` executable for your operating system.
  - Symlink the `undroidwish` binary somewhere in your path.
    - On Mac OS X, for example, you could run `ln -s /Applications/undroidwish.app/Contents/MacOS/undroidwish /usr/local/bin/`. Depending on your filesystem permissions, you may have to use `sudo`.

Once you have Tcl/Tk on your system and `undroidwish` is in your `PATH`, you can then use the helper script [`de1plus/unde1plus.sh`][] to launch the [`de1plus/de1plus.tcl`][] DE1 app on your OS with undroidwish runtime.

```sh
cd de1plus
./unde1plus.sh
```

[`de1plus/de1plus.tcl`]: ../de1plus/de1plus.tcl
[`de1plus/unde1plus.sh`]: ../de1plus/unde1plus.sh

## Creating a Plugin (Extension)

Create a new directory for your plugin under `de1plus/plugins/your_plugin_name`, and create a `plugin.tcl` file as the entrypoint for your plugin. If your plugin will require configurable settings, you will want to also create a `settings.tdb` file in your plugin's directory.

```sh
de1plus/plugins/webhook
├── plugin.tcl
└── settings.tdb    # (optional, include initial values for your settings)
```

Rather than start from scratch, it may be helpful to start from the example plugin: `cp -rv de1plus/plugins/example/ de1plus/plugins/your_plugin_name`.

Note: For your plugin to be distributed and included in the build process, it must also be tracked in `de1plus/misc.tcl`.

### Plugin Basics

Plugins are written in Tcl and should be namespaced to `::plugins::your_plugin_name`. There are a set of standard variables that are used and displayed in the plugin selection page in the DE1 app (`author`, `contact`, `version`, `description`, `name`).

A plugin is roughly structured like below (pseudo-tcl):

```tcl
# de1plus/plugins/your_plugin_name/plugin.tcl
set plugin_name "your_plugin_name"

# Plugin is encapsulated in a namespace
namespace eval ::plugins::${plugin_name} {
  # Variables used to display on plugin selection page
  variable author "Foo"
  variable contact "foo@bar.com"
  # ... other variables for selection display

  # Run for all plugins during UI startup
  proc preload {} {
    set page_name "plugin_your_plugin_name_page_default"

    # Build UI for plugin
    add_de1_page "$page_name" "settings_message.png" "default"
    # ... more UI building

    return $page_name
  }

  # Actual entrypoint for initializing and setting up your plugin
  proc main {} {
    # Examples of work done here:
    # - Initialize or read settings
    # - Register listeners
    # - Start long-running processes
    # - ... your plugin's secret sauce
  }
}
```

## Lifecycle of Plugins

- During UI startup, `plugins load` procedure is started.
- Identify all plugins in `de1plus/plugins/*/plugin.tcl`.
- Preload all plugins.
  - Calls the plugin's `preload` procedure.
    - `preload` is where you should declaratively build your plugin's UI if it has one.
- For each enabled plugin, load them.
  - Runs the `main` procedure for each plugin.
    - `main` should be where you register the listeners your plugin cares about that will trigger its essential business logic.
    - `main` should be where you initialize settings or initialize/run other parts of your plugin.
  - Plugins may be disabled if hitting a loading error.

## Using Settings

Define the initial values for your plugin's settings in `de1plus/plugins/your_plugin_name/settings.tdb`. This file is used for storing and initializing the settings related to your plugin. Tip: Once you have settled on your initial set of settings values, you could add the file to the `.gitignore` as you're developing locally and settings are changing.

```tcl
# de1plus/plugins/your_plugin_name/plugin.tcl
# Declare local settings variable
variable settings

# Reading settings
$settings(amazing_feature)

# Writing settings
set settings(amazing_feature) 42
save_plugin_settings $plugin_name
```

## Testing Your Plugin

TODO

## Internationalization (i18n)

If you want to mark a string as ready for translation, use the `translate` procedure in place of the string expression. Decent Espresso has a global customer base, so it's best practice to make sure user-visible strings are marked for translation.

```tcl
# Untranslated string
do_something "Success!"

# String marked for translation:
do_something [translate "Success!"]
```

## Implementation Details

For the adventurous, you can find more details about how the plugin system is implemented in [`de1plus/plugins.tcl`](../de1plus/plugins.tcl).
