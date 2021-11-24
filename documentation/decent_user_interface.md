# Decent User Interface

## Contents
- [Objective](#objective)
- [Revision history](#revision_history)
- [Overview](#revision_history)
- [Example](#example)
- [History](#history)
- [Details and API](#api)
  - [Environment setup](#environment_setup)
  - [Themes, aspects and styles](#aspects)
  - [Fonts and symbols](#fonts)
  - [Images and sounds](#images_and_sounds)
  - [Pages](#pages)
  - [Visual items (GUI elements)](#items)


<a name="api_index"></a>

## API Index

- `dui`
  - dui init
  - dui canvas
  - [dui config](#dui_config)
  - [dui cget](#dui_cget)
  - [dui say](#dui_say)
  - _Non exported:_  dui::setup_ui
- `dui platform`
  - dui platform hide_android_keyboard
  - dui platform button_press
  - dui platform button_long_press
  - dui platform finger_down
  - dui platform finger_motion
  - dui platform button_unpress
  - dui platform xscale_factor
  - dui platform yscale_factor
  - dui platform rescale_x
  - dui platform rescale_y
  - dui platform translate_coordinates_finger_down_x
  - dui platform translate_coordinates_finger_down_y
  - dui platform is_fast_double_tap
- `dui theme`
  - [dui theme add](#dui_theme_add)
  - [dui theme set](#dui_theme_set)
  - [dui theme get](#dui_theme_get)
  - [dui theme exists](#dui_theme_exists)
  - [dui theme list](#dui_theme_list)
- `dui aspect`
  - [dui aspect set](#dui_aspect_set)
  - [dui aspect get](#dui_aspect_get)
  - [dui aspect exists](#dui_aspect_exists)
  - [dui aspect list](#dui_aspect_list)
- `dui font`
  - [dui font add_dirs](#dui_font_add_dirs)
  - [dui font dirs](#dui_font_dirs)
  - [dui font load](#dui_font_load)
  - [dui font get](#dui_font_get)
  - [dui font list](#dui_font_list)
  - dui font width
  - _Non exported:_  dui::font::add_or_get_familyname, dui::font::key
- `dui symbol`
  - [dui symbol_set](#dui_symbol_set)
  - [dui symbol get](#dui_symbol_get)
  - [dui symbol exists](#dui_symbol_exists)
  - [dui symbol list](#dui_symbol_list)
- `dui image`
  - [dui image add_dirs](#dui_image_add_dirs)
  - [dui image dirs](#dui_image_dirs)
  - [dui image find](#dui_image_find)
  - _Non exported:_  dui::image::photoscale, dui::image::find, dui::image::load, dui::image::is_loaded, dui::image::get, dui::image::set_delayed, dui::image::exists_delayed, dui::image::load_delayed, dui::image::rm_delayed.
- `dui sound`
  - [dui sound set](#dui_sound_set)
  - [dui sound get](#dui_sound_get)
  - [dui sound exists](#dui_sound_exists)
  - [dui sound make](#dui_sound_make)
  - [dui sound list](#dui_sound_list)  
- `dui page`
  - [dui page add](#dui_page_add)
  - [dui page delete](#dui_page_delete)
  - [dui page theme](#dui_page_theme)
  - [dui page exists](#dui_page_exists)
  - [dui page type](#dui_page_type)
  - [dui page is_setup](#dui_page_is_setup)
  - [dui page is_drawn](#dui_page_is_drawn)
  - [dui page is_visible](#dui_page_is_visible)
  - [dui page bbox](#dui_page_bbox)
  - [dui page current](#dui_page_current)
  - [dui page previous](#dui_page_previous)
  - [dui page list](#dui_page_list)
  - [dui page get_namespace](#dui_page_get_namespace)
  - [dui page load](#dui_page_load)
  - [dui page show](#dui_page_show)
  - [dui page open_dialog](#dui_page_open_dialog)
  - [dui page close_dialog](#dui_page_close_dialog)
  - [dui page add_action](#dui_page_add_action)
  - [dui page actions](#dui_page_actions)
  - [dui page recreate](#dui_page_recreate)
  - [dui page retheme](#dui_page_retheme)
  - [dui page resize](#dui_page_resize)
  - [dui page moveto](#dui_page_moveto)
  - [dui page items](#dui_page_items)
  - [dui page has_item](#dui_page_has_item)
  - [dui page split_space](#dui_page_split_space)
  - dui page update_onscreen_variables
  - dui page calc_x, dui page calc_y, dui page calc_width, dui page calc_height
  - _Non exported:_  dui::page::setup, dui::page::add_items, dui::page::add_variable, dui::page::load_if_widget_enabled.
- `dui item`
  - [dui item add](#dui_item_add)
  - [dui item delete](#dui_item_delete)
  - [dui item get](#dui_item_get)
  - [dui item get_widget](#dui_item_get_widget)
  - [dui item pages](#dui_item_pages)
  - [dui item config](#dui_item_config)
  - [dui item cget](#dui_item_cget)
  - [dui item enable](#dui_item_enable)
  - [dui item disable](#dui_item_disable)
  - [dui item enable_or_disable](#dui_item_enable_or_disable)
  - [dui item show](#dui_item_show)
  - [dui item hide](#dui_item_hide)
  - [dui item show_or_hide](#dui_item_show_or_hide)
  - [dui item moveto](#dui_item_moveto)
  - [dui item listbox_get_selection](#dui_item_listbox_get_selection)
  - [dui item listbox_set_selection](#dui_item_listbox_set_selection)
  - _Non exported:_  dui::item::relocate_text_wrt, dui::item::relocate_dropdown_arrow, dui::item::ensure_size, dui::item::set_yscrollbar_dim, dui::item::scale_scroll, dui::item::scrolled_widget_moveto, dui::item::rounded_rectangle, dui::item::rounded_rectangle_outline, dui::item::scale_moveto, dui::item::drater_draw, dui::item::drater_clicker, dui::item::horizontal_clicker, dui::item::vertical_clicker, dui::item::anchor_inside_box, dui::item::anchor_coords.
- `dui add`
  - [dui add theme](#dui_add_theme)
  - [dui add aspect](#dui_add_aspect)
  - [dui add symbol](#dui_add_symbol)
  - [dui add page](#dui_add_page)
  - [dui add font](#dui_add_font)
  - [dui add font_dirs](#dui_add_font_dirs)
  - [dui add image_dirs](#dui_add_image_dirs)
  - [dui add canvas_item](#dui_add_canvas_item)
  - [dui add widget](#dui_add_widget)
  - [dui add dtext](#dui_add_dtext)
  - [dui add variable](#dui_add_variable)
  - [dui add image](#dui_add_image)
  - [dui add shape](#dui_add_shape)
  - [dui add dbutton](#dui_add_dbutton)
  - [dui add dclicker](#dui_add_dclicker)
  - [dui add dselector](#dui_add_dselector)
  - [dui add dtoggle](#dui_add_dtoggle)
  - [dui add entry](#dui_add_entry)
  - [dui add multiline_entry](#dui_add_multiline_entry)
  - [dui add text](#dui_add_text)
  - [dui add listbox](#dui_add_listbox)
  - [dui add dcheckbox](#dui_add_dcheckbox)
  - [dui add scale](#dui_add_scale)
  - [dui add dscale](#dui_add_dscale)
  - [dui add drater](#dui_add_drater)
  - [dui add graph](#dui_add_graph)
- `dui args`
  - _Non exported:_  dui::args::add_option_if_not_exists, dui::args::remove_options, dui::args::has_option, dui::args::get_option, dui::args::extract_prefixed, dui::args::process_tags_and_var, dui::args::process_aspects, dui::args::process_font, 
dui::args::process_label, dui::args::process_sizes, dui::item::dselector_click, dui::item::dselector_draw, dui::item::dtoggle_click, dui::item::dtoggle_draw.


<a name="objective"></a>

## Objective

This document describes usage of the `de1_dui` ("Decent User Interface") Tcl package to create the user interface 
of the Decent espresso machine DE1 app.

The DE1 app GUI is built with the [Tk toolkit](https://wiki.tcl-lang.org/page/Tk). Tk was designed for desktop 
applications, so it's not adapted to a tablet touch interface out-of-the-box, but offers enough flexibility for it to
be used. The DE1 app is one of the first usages of a viable Tcl/Tk-based tablet commercial app.

The first versions of the DE1 app (up to 1.3?) included a number of commands to help build such a user interface on top 
of Tk, offering a simple and elegant solution. This GUI infrastructure code, though, was not encapsulated in its 
own layer, and "bussines logic" was sometimes mixed with the GUI building logic. 
Also the code was not optimized for reuse and encouraged copying and pasting big chunks of code which made it 
harder and harder to maintain.

The objective of the `de1_dui` package (abbreviated DUI from now on) is to encapsulate all of the DE1 app GUI 
infrastructure functionality into its own framework layer, extending its existing mechanisms so that client code in 
skins and extensions can build new GUI pages and elements with minimal effort.

If you want to learn Tk, I highly recommend Welch & Jones' book 
[Practical Programming in Tcl and Tk](https://wiki.tcl-lang.org/page/Book+Practical+Programming+in+Tcl+and+Tk) 
(has some outdated constructs as it's for Tcl 8.4, but still one of the best books for learning the language and 
toolkit basics), and the [TkDocs online tutorial](https://tkdocs.com/).

<a name="revision_history"></a>

## Revision History

* 2021-04-10 – Initial writing by [Enrique Bengoechea](https://github.com/ebengoechea)
* 2021-04-11 - 2021-07-18 - Rewrite while the API evolves through nightly & beta, by [Enrique Bengoechea](https://github.com/ebengoechea)
* 2021-09-16 - Update for dialog pages and related changes, by [Enrique Bengoechea](https://github.com/ebengoechea)
* 2021-10-27 - `dui::add::dbutton` gets a new `-longpress_cmd` option, by [Enrique Bengoechea](https://github.com/ebengoechea)
* 2021-10-28 - Define the radius of each corner separately in rounded rectangles shapes and buttons, by [Enrique Bengoechea](https://github.com/ebengoechea)
* 2021-11-08 - New controls `dselector` and `dtoggle`, by [Enrique Bengoechea](https://github.com/ebengoechea)



<a name="history"></a>

## History

The DE1 app was developed by [John Buckman](https://github.com/decentjohn), cofounder of [Decent Espresso](https://decentespresso.com/), and it included all the mechanisms to build an elegant platform-independent touch interface on top of Tk.

The DUI package first release was developed by [Enrique Bengoechea](https://github.com/ebengoechea) as an extension of the existing GUI infrastructure code in the DE1 app, to make skin and extension writing for the Decent espresso machine easier. It came as an spin-off from the Describe Your Espresso (DYE) plugin, which started as a DSx plugin. Migrating it to a DE1 app plugin required lots of GUI changes, so the GUI part was taken off DYE and moved to its own plugin, DGUI. Then, the interest of [Johanna](https://github.com/mimoja) encouraged Enrique to refine it and make into the core DE1 app.

Much of DUI first release took code and ideas from [Barney](https://github.com/barneyhawes)'s Metric skin, [Damian](https://github.com/damian-au)'s DSx skin, and [Johanna](https://github.com/mimoja)'s MimojaCafe skin.


<a name="overview"></a>

## Overview

DUI uses a [canvas widget](https://www.tcl-lang.org/man/tcl/TkCmd/canvas.htm) to build the GUI. All GUI elements are
added to this canvas, whose handle can be obtained with command `dui canvas`.

Canvas as a widget offers 3 main features:

1. A drawing plane for "canvas items": text, lines, rectangles, ovals, polygons, and arcs. Some DE1 app controls are
built directly from these primitives, in order to offer a more modern-looking tablet-style interface than the standard
Tk widgets.

2. A container and geometry manager for other Tk widgets.

3. The ability to name and group elements together for creation, deletion, access, moving, etc., via the powerful tags 
mechanism.

The DUI canvas is initialized on startup and works as the Tk [geometry manager](https://wiki.tcl-lang.org/page/Geometry+Managers). All children elements (canvas items and Tk widgets, which we'll, from now on, refer to as "visual items" or "GUI elements") are positioned and sized on it using coordinates and dimensions in a fixed-size, non-scrollable space of 2560x1600 pixels.
DUI transforms all these coordinates and sizes to the actual ones depending on the current screen resolution.

The interface is organized in [pages](#pages). A page is just a named background element (either an image or a colored rectangle) with visual items added on top. Each visual item can be added to one or several pages, which allows easily building sets of similar pages that share most of their GUI elements. Pages are usually defined on startup:

1. In skins, on the outermost code that is evaluated when the code is sourced, or in procedures invoked from there.
2. In extensions, on code launched from either the `preload` or `main` namespace commands.

Nevertheless, for code clarity and proper encapsulation, creating pages directly in the outermost code is no longer recommended. Where possible, it is suggested to use the new [page namespace](#page_namespaces) mechanism instead (see below).

[GUI elements](#items) are added to pages using the `dui add <item_type> <page> <coordinates> <args>` family of 
commands, which are similar to the previous `add_de1_<item_type>` procedures. These commands are the workhorse
of DUI. They offer a *facade* to the lower-level Tk interface and add a good number of facilities on top:

1. Transform all coordinates and dimensions from a fixed-size space of 2560x1600 to the actual resolution in use.
2. *[New]* Assign meaningful labels to all visual items added to the canvas, using the canvas tag system. The labels are based 
on the first  element of the list provided by the calling code in the `-tags` argument, or on automatically-generated 
labels if `-tags` is not provided.
3. *[New]*  Assign default values to most widget creation options to define their aspect (font, colors, etc.) using themes
and styles. Client code is thus relieved from having to define each of these options on each call and aspect changes 
can be done globally with just a few lines of code.
4. If the element is a Tk widget, create the widget (which is necessary, before it can be added it to the canvas)
5. *[New]* Create extra visual items in *compound* GUI controls, such as labels for most widgets, scrollbars for listboxes and 
multiline text entries, images and icons in buttons, etc., and label all of them so they can easily be retrieved later.
6. *[New]* Create connection code between these items, if necessary. For example, dynamically place scale scrollbars on the side
of listboxes and make them work together with the listbox.
7. *[New]* Add common utilities (if requested), such as data validation or full-page editors for data input.
8. *[New]* If page namespaces are used, add references to all created visual items in the page namespace `widgets` array,
and use the namespace `data` array as default for any non-fully qualified variable used in the visual controls.
9. Add the visual items to the canvas, hidden.
10. Assign each visual item to the pages where it should appear.
11. Return the handle of the created item (canvas IDs for canvas items, and pathnames for Tk widgets)

Note that the `add_de1_<type>` commands in use before DUI only tackled the steps without *"[New]"*.
All others needed to be handled by skin/plugin code, but now are directly provided by the framework.

After the pages and all its visual elements are created, normally during app startup, they are shown during the app lifecycle using the `dui page show <page_name> <args>` command. This will hide all the canvas items of the currently visible page, and show all the canvas items of the new page. Client code can create 
callbacks that run whenever a specific page is setup, loaded (after the `page show` command is invoked, but before the page is shown), after the page is shown, or when the page is hidden. This can be done by creating standard procs (named `load`, `show` and `hide`) in the page namespace, or by using command `dui page add_action` if page namespaces are not useed.

<a name="example"></a>

## Example

(TBD)

<a name="api"></a>

## Details and API

The `de1_dui` package offers a single command: `dui`. This is an namespace ensemble with several ensemble subcommands:
`dui theme`, `dui aspect`, `dui font`, `dui page`, `dui item` and `dui add`, each of which offers 
its own set of commands.

### Some design considerations

Most code in DUI only extends what was already there in the DE1 app, but trying to formalize everything into its own layer and generate a consistent API. Although most features are designed to be backwards compatible, the API itself has been conceived forward-looking. For example, internal consistency in naming arguments and commands has been given priority whenever it conflicted with existing argument or command names.

For theming and styling both the Tk [resource database](https://wiki.tcl-lang.org/page/option+database) and Tk 
[themed widgets](https://tkdocs.com/tutorial/styles.html) were evaluated as possible solutions, but none seemed ideal for our needs.

I also opted for building item/widget compound bundles in a very simple way: manipulate the **args** and wrap calls to create a  _facade_ . I considered other alternatives, like [overloading megawidgets](https://wiki.tcl-lang.org/page/Overloading+widgets), but that seemed to add unneeded complexity vs the simple design here, which is relatively easy to follow and still allows low-level access by client code to everything. Probably something like [snit](https://core.tcl-lang.org/tcllib/doc/tcllib-1-18/embedded/www/tcllib/files/modules/snit/snit.html) would have been a very good option, but I found it too late.

Canvas-based new controls have their names prefixed by a "d" (**d**button, **d**slider, **d**checkbox, etc.) Currently they don't keep state internally, but depend on the global or namespace variable they reflect, and have all necessary parameters passed to them on the callbacks built at runtime when the are created and added to pages. This means that they are controlled indirectly by manipulating the variable, and there are no methods no modify their configuration (such as minimum and maximum values accepted) after creation. This shouldn't be hard to change in the future, if the need arises.

It is highly recommended that code in skins and extensions use as little low-level Tk functionality as possible, and try to use DUI calls instead. This should make it much more future-proof. If you find needing to write code that tweaks how DUI makes things, please consider adding your extensions to the core DUI by making a GitHub Pull Request.

As an example, using a canvas as the topmost widget is at the heart of DUI, but there are [canvas alternatives](https://wiki.tcl-lang.org/page/Alternative+Canvases) that may offer additional functionality with an almost identical API, like [tkpath](https://wiki.tcl-lang.org/page/tkpath), so that may change in the future. You will be shielded against such a change if you always use `[dui canvas]` or `[dui item config]` instead of `.can` and `.can itemconfig`.

<a name="environment_setup"></a>

### Environment setup

In the current alpha version, DUI coexists with the previous GUI infrastructure code, sharing most of the startup
configuration, so little setup is needed. As DUI replaces existing code in forthcoming versions, more of the
environment setup will move here.

At the moment, the only required initialization is the definition of the folders where to look for images and fonts 
(DUI will look up files on each folder in the list starting by the first element until a match is found).

```tcl
dui font add_dirs "[homedir]/fonts"
dui item add_image_dirs "[homedir]/skins/Insight" "[homedir]/skins/default"
```

You can change some default behaviours with the `dui config` command, or obtain their values with `dui cget`. 
The following options are suported (`<boolean>` may be any value that can be casted to a boolean: 0/1, yes/no, 
true/false, etc. as accepted by `[string is true]`).


<a name="dui_config"></a>

**dui config**  _option value_   _?option value...?_

	Sets the value of a global dui configuration option. Most options are boolean, and its value is coerced to 0/1 using `[string is true]`. Valid options are:

- **debug_buttons** (default 1) Set to 1 while debugging to draw a border around "clickable" areas. May need to redefine the border color using aspect `<theme>.dbutton.debug_outline` to make it visible against the theme background.

- **create_page_namespaces** (default 0) Set to 1 to default to create a namespace ::dui::page::<page_name> for each new created page, unless a different namespace is provided in the `-namespace` option of `dui page add`.

- **trim_entries** (default 0) Set to 1 to trim leading and trailing whitespace from modified values in entry boxes.

- **use_editor_pages** (default 1) Set to 1 to default to use editor pages if available (currently only for numbers).


<a name="dui_cget"></a>

**dui cget**  _option_

>Returns the current value of the requested configuration option.

 
<a name="aspects"></a>

### Themes, aspects and styles

 A theme is just a name that serves as grouping for a set of aspect variables. Themes define a "visual identity", by
 setting default option values for all widgets (colors, fonts, anchoring, etc.) Each of these options is called an "aspect".

Whenever a new visual item is added to a page, the default aspects will be automatically applied to the widget or canvas 
item according to its type (text / variable / entry / listbox etc.), unless a different value is explicitly added on the 
`gui add <item_type>` call.

Furthermore, each item or widget type can have any number of styles, which are sets of options with a specific appearance. 
For example, we may define styles for text items like "tab_header", "page_title", etc. Client code only needs to add 
argument `-style tab_header` to apply all the style aspects at once, and may overwrite any individual aspect 
by just providing it using `dui add <item_type> (...) -option value`.

A theme called *default* comes included. It provides default aspects corresponding to the Insight visual identity.


Aspects are stored using a 4-word syntax separated by dots, though the last word (&lt;style_name&gt;) is optional:

```tcl
<theme_name>.<type_name>.<option_name>.<style_name>
```

Aspects are defined using `dui aspect add`. The full aspect can be provided, or, more often, the **-theme**,
**-type** and **-style** options are applied to all given arguments. These three calls do the same:

```tcl
dui aspect add -theme dark -type text -style \
	tab_header font_family \
	notosansuiregular font_size 20
	
dui aspect add dark.text.font_family.tab_header notosansuiregular dark.text.font_size.tab_header 20

dui aspect add -theme dark {
	text.font_family.tab_header 
	notosansuiregular text.font_size.tab_header 20
}
```

Example code:

```tcl
package require de1_dui 1.0
dui theme add dark
dui aspect add -theme dark {
    page.bg_color "#edecfa"
    text.font_family notosansuiregular
    text.font_size 16
    text.fill "#7f879a"
    text.activefill orange
    text.disabledfill "#ddd"
    text.anchor nw
    text.justify left 
    text.font_family.tab_header notosansuibold
    text.font_size.tab_header 20
    entry.relief sunken
        ... 
    }

# From now on all aspect defaults will be from the dark theme
dui theme current dark 

# Create a page with the dark theme aspect defaults, so will use page.bg_color from that theme
dui page add test_page

# Will use a bigger font, otherwise will use the theme text.* aspects
dui add dtext test_page 1280 100 -text [translate "Tab title"] -style tab_header

# Will use all text.* aspects from the dark theme, except -fill
dui add dtext test_page 200 200 -text [translate "Some text"] -fill black
```

<a name="aspects_api"></a>

#### Themes, aspects and styles API

#### `dui theme`

<a name="dui_theme_add"></a>

**dui theme add**  _theme_name_   _?theme_name ...?_

>Adds all the provided names to the list of valid themes.


<a name="dui_theme_set"></a>

**dui theme set**  _theme_name_

>Sets the current active theme. This theme will be used on all `dui add <item_type>` commands from this point in the code until a new theme is set. The theme name is added to the list of valid themes if it's not already in the list.

>If you want an individual page to use a theme different from the current one when the page items are setup, use the **-theme** argument of <a href="#dui_add_page">dui add page</a>. This only applies to pages that have a namespace.

>You can also make pages with namespaces be recreated using a different theme, using <a href="#dui_page_retheme">dui page retheme</a>.


<a name="dui_theme_get"></a>

**dui theme get**

>Returns the name of the currently active theme.


<a name="dui_theme_exists"></a>

**dui theme exists**  _theme_name_

>Returns whether the provided theme name has been added to the list of valid themes.


<a name="dui_theme_list"></a>

**dui theme list**

>Returns a list with all valid themes.

#### `dui aspect`

<a name="dui_aspect_set"></a>

**dui aspect set**  _?-option value ...?  aspect aspect  ?aspect value ...?_

**dui aspect set**  _?-option value ...? list_of_aspect-value_pairs_

>Define aspect values that will be used as default options when a visual item of type <type_name> is created using `dui add <type_name>`. Aspect values take the form &lt;theme&gt;.&lt;type&gt;.&lt;option&gt;.&lt;style&gt;, where &lt;style&gt; is optional.
Aspects can be defined using the full name, or options **-theme**, **-type** and **-style** can be specified and they will be added to all the aspect names in the call.
If not stated otherwise in the aspect name or the **-theme** option, the currently active theme is used.

>The following types are currently supported: page, font, text, symbol, entry, entry_label, dbutton, dbutton_label, dbutton_symbol,  dcheckbox, dcheckbox_label, listbox, listbox_label, scrollbar, dscale, dscale_label, scale, scale_label, rect, line. It will also work with new types of Tk widgets added with `dui add widget` and canvas items added with `dui add canvas_item`. 

>The possible values are those accepted by the corresponding `dui add <type>` command, widget create command, or canvas create command.


<a name="dui_aspect_get"></a>

**dui aspect get**  _type aspect ?-option value ...?_

>Return the value of the requested aspect, under the currently active theme unless the aspect name defines other theme or the **-theme** option is specified.  _type_  can be a list of types, in that case each type will be searched (from first to last in the list) until a matching aspect is found.

>Named options:

>**-theme**  _theme_name_ 

>**-style**  _style_name_

>**-default**  _option_value_

> >Value to return in case the requested aspect is not defined.

>**-default_type**  _type_

> >If the aspect is not defined for the requested type, try the same option for this type as default. Normally used internally and not so much for final user code. Now that  _type_  accepts a list of types this is no longer needed, but still kept for backwards-compatibility.


<a name="dui_aspect_exists"></a>

**dui aspect exists**  _type aspect ?-option option_value ...?_

>Return whether the specified aspect exists. Uses the same options as **dui aspect set**.


<a name="dui_aspect_list"></a>

**dui aspect list**  ?-option option_value ...?_

>Return a list of all requested aspects. 

>Named options:

>**-theme**  _theme_name_ 

>**-type**  _type_name_

>**-style**  _style_value_

> >Restricts to the requested  _theme_ ,  _type_ , or  _style_  names.

>**-values**  _boolean_

> >If  _true_ , returns a list of aspect_name-value pairs. If  _false_ , only returns the aspect names. Default is  _false_ .

>**-full_aspect**  _boolean_

> >If  _true_ , the aspect names returned are full names `<theme_name>.<type_name>.<option_name>.<style_name>`. If  _false_ , only the option name is returned. Default is  _false_ .

>**-as_options**  _boolean_

> >If  _true_ , returns a list of option_names-value pairs. The option names are prefixed by a "-" character, so that using `-as_options yes` allows to use the result directly as options in a widget creation command. Default is  _false_ . When set to  _true_ , automatically **-values** is  _true_  and **-full_aspect* is  _false_ .


<a name="fonts"></a>

### Fonts and symbols

(PENDING DETAILS)

<a name="dui_font_add_dirs"></a>

**dui font add_dirs**  _dirname ?dirname ...?_

>Append new folders to the list of directories that will be searched when an font filename is searched for.

<a name="dui_font_dirs"></a>

**dui font dirs** 

>Returns the list of font directories used when searching for font.

<a name="dui_font_load"></a>

**dui font load**  _filename size ?-name font_name? ?-weight normal_or_bold? ?-slant roman_or_italic? ?-underline boolean? ?-overstrike boolean?_

>Loads fonts with the specified parameters.

<a name="dui_font_get"></a>

**dui font get**  _fontname_or_filename size ?-name font_name? ?-weight normal_or_bold? ?-slant roman_or_italic? ?-underline boolean? ?-overstrike boolean?_

>Gets the font matching the provided specification. If it's not loaded yet, it's automatically loaded.

<a name="dui_font_list"></a>

**dui font list**  _?loaded?_ 

>Returns a list of either all fonts loaded with <a href="#dui_font_load">dui font load</a> (if  _loaded_  is  _false_ , the default), or of all Androwish loaded fonts (if  _loaded_  is  _true_ ).


<a name="dui_symbol_set"></a>

**dui symbol set**  _symbol_name unicode_value ?symbol_name unicode_value ...?_ 

>Defines Fontawesome 5 regular symbols by name. Not that this is **not needed** anymore except for defining alternative names, as since 1.35.2 the whole set of Fontawesome symbols names is preloaded.

<a name="dui_symbol_get"></a>

**dui symbol get**  _symbol_name_ 

>Returns the unicode value corresponding to  _symbol_name_ .

<a name="dui_symbol_exists"></a>

**dui symbol exists**  _symbol_name_ 

>Returns whether  _symbol_name_  is a defined symbol.

<a name="dui_symbol_list"></a>

**dui symbol list**

>Returns the list of all defined symbol names.


<a name="images_and_sounds"></a>

### Images and sounds

DUI implements 3 facilities for all images that previously were only available for page background images: resizing, caching, and preloading vs delaying load. These are implemented internally by a set of `dui image` subcommands that are not exported, as they are called automatically by DUI when `dui add image` or `dui page load` are used.

**Images finding and resizing**

If a relative path is provided to image commands such as `dui add image`, DUI searches for the file in its image search paths list. By default this includes images in subfolder **&lt;current_screen_width&gt;x&lt;current_screen_height&gt;** of the default skin, then in subfolder **&lt;current_screen_width&gt;x&lt;current_screen_height&gt;** of the active skin. Any other image directory must be explicitly added with `dui image add_dirs`.

If the requested file is not found in any of the search paths, and option  _rescale=1_  is set (the default), then the same file is searched for in the **2560x1600** subfolders and, if found, the image is automatically rescaled and stored in **&lt;current_screen_width&gt;x&lt;current_screen_height&gt;**, so it doesn't have to be rescaled again next time.

Search paths are tried in the order in which they were originally added.

**Images caching**

The first time an image is loaded, it is indexed by its normalized file path. Subsequent usages of the same path image automatically reuse the image that is already loaded. This is automatic and transparent to client code.

**Preloading vs delayed loading**

DUI setting parameter **preload_images** controls whether images are preloaded (loaded into memory from their path names) when they are setup with the `dui image add` command, or whether its loading is delayed until the first time a page in which the image appears is shown. The default value of **preload_images** is initialized by the DE1 app to the value of the global setting **preload_all_page_images**.


#### Images and sounds API
 
<a name="dui_image_add_dirs"></a>

**dui image add_dirs**  _dirname ?dirname ...?_

>Append new folders to the list of directories that will be searched when an image filename with a relative path is provided to **dui add image**. Note that this must be the  _parent_  folder that contains subfolders for each available screen resolution. For the DE1 app, the default image search path includes the default skin folder, and the active skin folder.

<a name="dui_image_dirs"></a>

**dui image dirs** 

>Returns the list of image directories used when searching for images.

<a name="dui_image_find"></a>

**dui image find**  _filename ?rescale?_

>Locates an image filename in the file system, and optionally rescales it if it's available in the base resolution but not in the current screen resolution. This is normally invoked automatically by DUI in `dui add image` commands, it doesn't have to be called by client code.


**dui sound set**  _sound_name filename ?sound_name filename ...?_

>Defines sounds by name.

<a name="dui_sound_get"></a>

**dui sound get**  _sound_name_

>Gets the filename associated to a sound name.

<a name="dui_sound_exists"></a>

**dui sound exists**  _sound_name_

>Returns whether the  _sound_name_  is a defined sound.

<a name="dui_sound_make"></a>

**dui sound make**  _sound_name_

>Makes the sound.

<a name="dui_sound_list"></a>

**dui sound list**  _?paths?_

>Returns the list of defined sounds. If  _paths_  is  _true_ , return sound_name-filename pairs, if  _false_  (the default), returns only the sound names.

<a name="dui_say"></a>

**dui say**  _message ?sound_name?_

>Shows a message toast or makes a sound.


<a name="pages"></a>

### Pages

GUI elements are placed into pages. Internally they are all canvas children that are just initialized in a hidden state.
DUI tracks which elements appear on each page, and shows the right ones when a page is requested to be shown, 
hiding all others.

Each page is just a background element, which can be either an image or a colored shape (rectangle, rounded-corners rectangle, etc.)
This element receives the same label as the page name. Once the page is added, visual items can be added to it at fixed 
coordinates relative to the page top-left position, in a theorical 2560x1600 pixels space. The coordinates and other dimension options are mapped automatically to the current resolution. Coordinates can be given in pixels (if they are >1) or in percentage from the available space (if they are >=0 and <1). Note that  _only landscape screen/tablet position is supported_ .

There are 3 types of pages, and this is defined in the [dui page add](#dui_page_add) command:

1. `default`: standard pages that occupy the whole screen. They're "independent pages" in the sense that the previous
page stack that led to them is not kept.

2. `dialog`: pages that don't occupy the whole screen, i.e. they are shown on top of the page that opens them. By default,
when a dialog is closed it returns control to the page that launched it. The DUI framework keeps a stack of open dialogs 
and returns control to the previous page when a dialog is closed, executing an optional return callback for communication
between pages. Nevertheless, dialogs are not really modal windows, as there are several circumstances that divert the flow
to a page different to the one that opened the dialog: when a GHC command is started; when the machine ends initial 
heating; or when the screensaver is triggered. Programmers must take this into account and properly persist relevant 
information for when these cases arise. The "hide" [page action](#page_actions) is very useful for taking care of this
situation.

3. `fpdialog` (full page dialog): pages that occupy the whole screen like "default" pages, but that behave like 
"dialog" pages in their workflow.


Pages and their child elements are normally built during startup, then pages are shown or hidden during the app session 
lifecycle, whenever `dui page show*` commands are used.
But if namespace pages are used, there is total freedom to define their life cycle at runtime, as they can be 
[added](#dui_page_add), [removed](#dui_page_remove) and [recreated](#dui_page_recreate) at any moment.

Each visual item can appear in more than one page, which makes it easy to build sets of similar pages with just some
differences.

The order in which visual items are added to pages is exactly the same order in which they will be shown. 
This may be very relevant for certain controls. For example, "clickable" areas in a button should always be added
last so they are not hidden totally or partially by other controls (which would make them non-clickable). Of course,
this can be controlled at runtime with canvas commands **lower** and **raise**, but it's usually easier to avoid problems 
adding items in the correct order.

<a name="page_namespaces"></a>

#### Page namespaces

Before DUI, pages creation code was often placed directly in the outermost script of skins and at times scattered through several source code files, making it hard to follow and maintain. Mostly global variables were used for keeping page state and data, which made it too easy to pollute the global context with stuff and was prone to name clashing, especially with the increasing amount of available skins and extensions.

Although this code style is still supported, it is highly recommended that UI code is migrated to use the new **page namespaces**. The idea is to encapsulate the code and the data of each page (or set of related pages) into its own namespace. This not only improves readability and maintenance, but makes it much easier to build pages because DUI supports some conventions that facilitate it:

1. Each page namespace contains by default 2 arrays:
	- The **widgets** array contains handles to all the page visual items, indexed by the first tag name provided in the **-tags** option of each **dui add &lt;type&gt;** command.
	- The **data** array contains page data. Non-qualified variable names in calls to **dui add &lt;type&gt;** commands 	automatically use data from this array (and auto-set it as necessary), simplifying the **dui add** syntax and promoting usage of namespace variables instead of global variables.
2. If the page namespace includes commands whose names match the [page events](#page_actions) **setup**, **load**, **show**, **hide** and **update_vars**, they are automatically called by DUI at the specific event.

DUI offers the base namespace **::dui::pages** where page namespaces can be created as children, and uses it as default, but doesn't require you to use it. Any namespace can be used, by declaring it with the **-namespace** option of the <a href="#dui_page_add">dui page add</a> command.

Another advantage of using page namespaces is that pages can be completely rebuilt on the fly, for example to change their aspect to anooher skin. See commands [dui page recreate](#dui_page_recreate) and [dui page retheme](#dui_page_retheme).


<a name="page_actions"></a>

#### Page actions / events

Page actions are Tcl code callbacks that are executed at different points in the page lifecycle. They are similar to Tk widgets bindings. They serve to customize the application workflow in general or in specific pages.

Page actions can be defined implicitly when using namespaces by defining the namespace commands **setup**, **load**, **show**, **hide** and **update_vars**, or explicitly for any type of page by calls to <a href="#dui_page_add_action">dui page add_action</a>. Note that event actions (either implicit or explicit) **need not be invoked directly**. They are all automatically executed by the DUI framework.

Page actions can apply to individual pages or to all pages (setting the  _page_  argument of **dui page add_action**  to an empty string). The latter serve to modify an application workflow.

Actions are executed in the following order when the event takes place:

1. First, explicit global actions (those that apply to  _all_ pages), in the order in which they were added in the code.
2. Second, the page-specific implicit action (for pages with namespaces, the proc whose name matches the event name).
3. Third, the page-specific explicit actions, in the order in which they were added in the code.

The following action types (or  _events_ ) are available:

##### setup
Takes place when the page user interface is defined, that is, when its widgets and canvas items are created. Setup actions are automatically called during app initialization if the page has been created using <a href="#dui_page_add">dui page add</a>. If a page is added after initialization, its setup events are triggered automatically the first time the page is loaded. They are also invoked whenever the page is deleted and re-created by command <a href="#dui_page_retheme">dui page retheme</a>.

##### load
Takes place whenever a <a href="#dui_page_load">dui page load</a> command is run,  _before_  the
page is actually shown. This proc is normally used to initialize page data, such as loading listboxes contents.With page namespaces, the **load** command can be used to pass opening arguments to the page. The first two arguments of the **load** proc must be the names of the pages to hide and show, plus any extra optional arguments that will be passed through from the <a href="#dui_page_load">dui page load</a> call. 

Though receiving the page to be shown as an argument on the **load** and **show** namespace commands may seem unnecessary, it is required when a single namespace is used for several related pages. Same argument for passing the name of the page to be hidden to the **hide** namespace command.

A page namespace **load** command must return either 0, 1, or a page name. This is used to optionally interrupt the loading of the page (if the return value is 0), or to diverge the flow to another page (if the return value is a new page name).

##### show 
Takes place whenever the <a href="#dui_page_load">dui page load</a> or <a href="#dui_page_show">dui page show</a> commands are run,  _after_  the page is actually shown. This event is normally used to initialize the page GUI elements (e.g. show/hide or enable/disable some items depending on the state).

With page namespaces, the **show** command first two arguments must be the names of the pages to hide and show.
	
##### hide
Takes place just after the currently visible page is going to be hidden, due to <a href="#dui_page_load">dui page load</a> or <a href="#dui_page_show">dui page show</a> commands that will show another page. Page cleanup is usually carried out on this event.

With page namespaces, the **hide** command first two arguments must be the names of the pages to hide and show.

##### update_vars
Takes place whenever the <a href="#dui_add_variable">page variables</a> values are updated. Beware this is a background task that is run very often while the page is visible (around every 100 milliseconds), so write efficient code for this event.


<a name="pages_api"></a>

#### Pages API

#### `dui page`

<a name="dui_page_add"></a>

**dui page add**  _page_name ?-option option_value ...?_

>Declares a new GUI page and creates its background canvas element (either an image or a solid color rectange).  _page_name_  can only have letters, numbers and underscores, and page names cannot be duplicated.

>Named options: 

>**-type**  _page_type_

> >Defines the type of page, which can be `default`, `dialog` or `fpdialog` (full page dialog).

>**-theme**  _theme_name_

> >Defines the theme to use for creating all the visual items of the page (during the **setup** actions). Used rarely, as the usual choice is to apply the default options from the current theme. The theme used when creating a page can be queried at any moment with <a href="#dui_page_theme">dui page theme</a>.

> >DUI will change temporarily the theme to  _theme_name_  while running the page *setup* actions if it differs from the active theme at that moment, and set it back after the page is setup. This means that the theme never needs to be set of modified in the setup actions themselves.

>**-style**  _style_name*

> >Uses as default options the aspects from style  _style_name_  for the **page** type. If an aspect is not defined
for the requested style, the unstyled aspect is used.

>**-bg_img**  _filename_

> >Uses an image as background. At the moment this case is delegated to the legacy proc **add_de1_page**. This has
precedence over **-bg_color**.

>**-bg_color**  _color_spec_

> >Background color of the background shape, in case no background image is defined.

>**-bg_shape**  _shape_

> >Background shape that ocuppies the full screen. A rectangle by default, but can be any other shape accepted by
[dui add shape](#dui_add_shape). Normally only dialog-type pages use a non-rectangular shape, such as a rounded-corners 
rectangle.

>**-namespace**  _true_false_or_namespace_

> >Either a boolean (1/0, true/false, etc.) or a fully qualified namespace name. If  _true_ , uses the page namespace 
**::dui::pages::&lt;page_name&gt;**; if  _false_ , no page namespace is used; otherwise uses the provided namespace.
If the namespace does not exist, it is created. If the namespace does not already have the **widgets** and **data** array
variables, they are created. If this option is not specified, it takes its default value from the DUI configuration 
variable **create_page_namespaces**.

>**-bbox**  _list_of_4_coordinates_

> >A list {x0 y0 x1 y1} that gives the top-left and bottom-right coordinates of the page bounding-box rectangle.
Only relevant for pages of type "dialog".


<a name="dui_page_delete"></a>

**dui page delete**  _page_name ?keep_data?_

>Deletes page  _page_name_ . All of its canvas items are removed, and its widgets destroyed. 

>set  _keep_data_ to 1 (default is 0) if the page is going to be recreated. This still destroys the canvas items and widgets, but retains the page actions and other data so it's available again when re-creating the page.


<a name="dui_page_theme"></a>

**dui page theme**  _default_ 

>Returns the name of the theme used when creating the page. If the page has no namespace (and thus has no theme assigned), returns  _default_ , which, if not specified, is an empty string.


<a name="dui_page_type"></a>

**dui page type**  _page_name_

>Returns the type of page  _page_name_ , which can be either "default", "dialog" or "fpdialog" (full page dialog).

<a name="dui_page_exists"></a>

**dui page exists**  _page_name_

>Returns whether the page  _page_name_  exists (=has been added).

<a name="dui_page_is_setup"></a>

**dui page is_setup**  _page_name_

>Returns whether the page has already been setup (i.e. its visual items have been created). This always return 0 for pages that haven't an associated namespace.

<a name="dui_page_is_drawn"></a>

**dui page is_drawn**  _page_name_

>Returns whether the page has already been drawn (shown) at least once. This is useful to be sure that page widgets have initialized their dimensions (though take into account that some page widgets may be have never been painted if they were created with option **-initial_state hidden**).

<a name="dui_page_is_visible"></a>

**dui page is_visible**  _page_name_

>Returns whether the requested page is currently visible.

<a name="dui_page_bbox"></a>

**dui page bbox**  _page_name ?rescale?_

>Returns a list with four elements {x0 y0 x1 y1} that give  top-left and bottom-right coordinates of the page current bounding 
box. This is useful for "dialog" pages, for "default" and "fpdialog" pages it always returns 2560x1600. 
If  _rescale_  is 0 (the default case), the coordinates are returned in the base 2560x1600 space, whereas if it is 1, the coordinates are rescaled to the current screen dimensions.

<a name="dui_page_current"></a>

**dui page current**

>Returns the name of the currently visible page.

<a name="dui_page_previous"></a>

**dui page previous**

>If the current page has type "dialog" or "fpdialog", returns the name of the page that launched the current dialog. 
If the current page hast type "default", returns an empty string.


<a name="dui_page_list"></a>

**dui page list**

>Returns the list of all added pages.


<a name="dui_page_get_namespace"></a>

**dui page get_namespace**  _page_name_

>Returns the page namespace of  _page_name_ , or an empty string if the page has no associated namespace.


<a name="dui_page_load"></a>

**dui page load**  _page_name ?args?_

**dui page show**  _page_name_

>If  _page_name_  has type=default or type=fpdialog, hides the currently visible page and shows the requested page. If  _page_name_  has type=dialog, disables the currently visible page elements and shows the requested dialog page on top of it. During this process, the [page actions](#page_actions) **load**, **show**, and **hide** are invoked if they exist in the page namespace; if there are explicit page actions matching the same events, they are invoked too. Each of these 3 callbacks is invoked using as 2 first arguments the name of the page to hide and the name of the page to show. 

>**dui page show** does the same as **dui page load** except that the **load** actions are not invoked. For example, this can be used when returning from a dialog page, when you want to re-show the page that invoked the dialog without re-loading its data.

>If the page to be shown is the same page to be hidden, nothing is done, except if the option **-reload yes** is passed to **dui page load**. This option is useful when a page needs to be reloaded from the same page (for example, to show different data).

>Named options:

>**-reload**  _{boolean}_

> >If  _true/yes/1/on_ , forces reloading the page when the page requested to be loaded is the same as the current one. Default is 0.

>**-return_callback**  _tcl_proc_name_

> >The fully qualified name of a tcl function that will process the parameters returned by the dialog when it is closed by calling [dui page close_dialog](#dui_page_close_dialog) and control is returned to the page that opened the dialog. This callback function must have arguments that match those given to dui::page::close_dialog call in the code. If no return callback is specified, no special processing is done when the dialog is closed. This can work, for example, if the dialog is used to modify a global variable which the calling page reads automatically. This callback is only executed when the dialog returns the the  _same_  page that opened it. If flow leads to a different page, the callback is not run.

>**-disable_items**  _boolean_

> >Whether canvas items in the background page (the one that invoked the dialog) are actually disabled (which may change their aspect) or not when the dialog is shown. Default is 1. Note that this only affects canvas items, Tk widgets are always disabled, or otherwise they would still accept events.


>All additional arguments in  _args_  are passed through to the page **load** command and/or to the page load actions. Use this to initialize pages with specific data, or for communication between pages, instead of relying on global variables.


<a name="dui_page_open_dialog"></a>

**dui page open_dialog**  _page_name ?-option option_value ...?_

>Open/Load the dialog page  _page_name_ . If  _page_name_  does not have type=dialog or type=fpdialog (full page dialog), does nothing.

>Named options: 

>**-coords**  _{x y}_

> >2-elements list that provides the [coordinates](#dui_coordinates) where the dialog will be open. By default this is the 
top-left point (anchor=nw), but this can be changed defining  _anchor_ . If this is not defined, the dialog will
be open on the same place it was last opened, or, if it has never been loaded, where it was created.

>**-anchor**  _anchor_

> >Defines how the dialog is positioned with respect to the reference coordinates  _{x y}_ . Default is "nw". Valid anchor values are "center", "n", "ne", "nw", "s", "se", "sw", "w", and "e".

>**-size**  _{width height}_

> >2-elements list that provides the size of the dialog. If they are different from the current dialog dimensions, the dialog page will be recreated (deleted and setup again with the new dimensions).

>**-return_callback**  _tcl_proc_name_

> >The fully qualified name of a tcl function that will process the parameters returned by the dialog when it is closed by calling [dui page close_dialog](#dui_page_close_dialog) and control is returned to the page that opened the dialog. This callback function must have arguments that match those given to dui::page::close_dialog call in the code. If no return callback is specified, no special processing is done when the dialog is closed. This can work, for example, if the dialog is used to modify a global variable which the calling page reads automatically. This callback is only executed when the dialog returns the the  _same_  page that opened it. If flow leads to a different page, the callback is not run.

>**-disable_items**  _boolean_

> >Whether canvas items in the background page (the one that invoked the dialog) are actually disabled (which may change their aspect) or not when the dialog is shown. Default is 1. Note that this only affects canvas items, Tk widgets are always disabled, or otherwise they would still accept events.

<a name="dui_page_close_dialog"></a>

**dui page close_dialog**  _?args?_

>Close the current dialog page and return control to the page that originally opened the dialog. If a  _return callback_  was provided on the dialog open call, it is executed  _after_  the dialog is hidden and the original page is shown (i.e. after all hide and show actions have occurred). The optional arguments  _args_  are passed to the return callback. Does nothing if the current page doesn't have type=dialog or type=fpdialog (full page dialog).


<a name="dui_page_add_action"></a>

**dui page add_action**  _page_name event tcl_code_

>Adds the callback [action](#page_actions) in  _tcl_code_  to the specified  _event_  of  _page_ . Possible events are **setup**, **load**, **show**, **hide** and **update_vars**. All added callback actions are run in the order in which they were added.

>If  _page_name_  is the empty string, the code will be run for  _all_  pages.

<a name="dui_page_actions"></a>

**dui page actions**  _page_name event_

>Returns a list with the tcl code of each [action](#page_actions) of the specified  _event_  of the given  _page_ . If  _page_name_  is the empty string, returns the actions that are to be run for  _all__ pages.

<a name="dui_page_recreate"></a>

**dui page recreate**  _page_name ?-option option_value ...?_

>Deletes page  _page_name_  and recreates it using a (possibly) different set of options. The page is recreated with the
same set of options used to create it the last time, except those that are defined here, which take precedence.
This only works with pages that have an associated namespace, as it requires a page **setup** command.

<a name="dui_page_retheme"></a>

**dui page retheme**  _page_name new_theme_

>Deletes page  _page_name_  and recreates it using a different theme. This only works with pages that have an associated namespace, as it requires a page **setup** command.

<a name="dui_page_resize"></a>

**dui page resize**  _page_name width height_

>Resizes a [dialog page](#pages) to a new  _width_  and  _height_ , in the base 2560x1600 space. If  _width_  or
_height_  are between 0 and 1, they are interpreted as percentages of the base space.

<a name="dui_page_moveto"></a>

**dui page moveto**  _page_name x y ?anchor?_

>Moves a [dialog page](#pages) to a new position given by coordinates  _x_  and  _y_ , in the base 2560x1600 space. 
_anchor_  defines how the dialog is positioned with respect to the reference coordinate given by {x y}, and has default
value "nw". Valid anchor values are "center", "n", "ne", "nw", "s", "se", "sw", "w", and "e".
If  _x_  or  _y_  are between 0 and 1, they are interpreted as percentages of the base space.


<a name="dui_page_items"></a>

**dui page items**  _page_name_

>Returns the list of canvas IDs of all visual items in page  _page_name_ .

<a name="dui_page_has_item"></a>

**dui page has_item**  _page_name tag_

>Returns whether  _tag_  corresponds to an item tag in page  _page_name_ .

<a name="dui_page_split_space"></a>

**dui page split_space**  _start  end  spec1 ?spec2? ?spec3? ..._

>Splits a vertical or horizontal page distance between  _start_  and  _end_  according to the specification given by each _spec_ , and returns a list of "cut" points with one more element than  _specs_ . Each item of  _specs_  has to be a positive value greater than 1 (fixed-pixel distance), or a positive value smaller than one (percentage of total), for each split. First the size of all fixed-pixel sizes will be removed from the total, then the remaining distance will be allocated to each percentage size according to its relative size (they don't have to add up to 1).



<a name="items"></a>

### Visual items (GUI elements)

GUI elements can be of two types:

1. **Canvas items**: text, images and painting primitives (lines, arcs, polygons, rectangles and ovals).
They are created directly in the canvas. 
2. **Tk widgets** or "windows": These need to be created before adding them to the canvas. The canvas acts as a 
container and geometry manager.

Each item is created and added to a [page](#pages) using a <strong>dui add &lt;item_type&gt;</strong> command.
These commands are the workhorse of the DUI package, as they try to make it as easy as possible to add GUI
elements, removing as much burden as sensible from client (skin & plugin) code. 

The <strong>dui add &lt;item_type&gt;</strong> family of commands perform a good number of actions:

1. Transform all coordinates and dimensions from a fixed-size space of 2560x1600 to the actual resolution in use.
2. Assign meaningful labels to all visual items added to the canvas, using the canvas tag system. The labels are based 
on the first  element of the list provided by the calling code in the `-tags` argument, or on automatically-generated 
labels if `-tags` is not provided.
3. Assign default values to most widget creation options to define their aspect (font, colors, etc.) using themes
and styles. Client code is thus relieved from having to define each of these options on each call and aspect changes 
can be done globally with just a few lines of code.
4. If the element is a Tk widget, create the widget (which is necessary, before it can be added it to the canvas)
5. Create extra visual items in *compound* GUI controls, such as labels for most widgets, scrollbars for listboxes and 
multiline text entries, images and icons in buttons, etc., and label all of them so they can easily be retrieved later.
6. Create connection code between these items, if necessary. For example, dynamically place scale scrollbars on the side
of listboxes and make them work together with the listbox.
7. Add common utilities (if requested), such as data validation or full-page editors for data input.
8. If page namespaces are used, add references to all created visual items in the page namespace `widgets` array,
and use the namespace `data` array as default for any non-fully qualified variable used in the visual controls.
9. Add the visual items to the canvas, hidden.
10. Assign each visual item to the pages where it should appear.
11. Return the handle of the created item (canvas IDs for canvas items, and pathnames for Tk widgets)


<a name="retrieving_items"></a>

#### Identifying and retrieving items

The canvas widget uses a powerful naming mechanism based of the **-tags** option of the **canvas create** command.
Each item added to the canvas can receive any number of tags, and several items can share the same tag. 
These tags can then be used to retrieve and perform operations on all items that match a given set of tags at once.
In addition, each item added to the canvas is automatically assigned a unique integer ID that can be used to retrieve the item.

Tk widgets, in addition, create a command in the global context based on their pathname. The default pathname
assigned by DUI concatenates the canvas pathname, the page name and the main canvas tag of the widget, for example
_.can.settings_2a-profiles_listbox_ .

For Tk widgets added to the canvas you can retrieve the widget pathname from the canvas ID or tag using 
**[dui canvas] itemcget &lt;tag_or_id&gt; -window**, but not the other way around. Nevertheless, DUI offers
helper methods such as **dui item get**, **dui item get_widget**, **dui item config** and **dui item cget** that
auto-detect item types and work equally with canvas items and Tk widgets, so it's recommended to use them.

Before DUI, the canvas tag mechanism was not accessible because the **add_de1_&lt;type&gt;** commands assigned an 
automatic tag based on counters and didn't allow client code to assign tags. An automatic tag is still assigned
in a similar way if the **dui add &lt;type&gt;** doesn't include a **-tags** option.

The **dui add &lt;type&gt;** family of commands manipulate the tags provided by the user in the following ways:

1. If no tag is specified, an automatic tag is created using auto-increment counters.

2. The first tag in the list of tags is considered the "main tag" and is used to name and retrieve the control.
It can only contain letters, numbers and underscore characters, and is required to be unique  _per page_ . 
This main tag is also used as the key in the page namespace `widgets` array variable, and as default key in the page
namespace `data` array variable when no variable is explicitly defined (for widgets associated to variables, 
such as entries, listboxes or scales).

3. Any extra user tags are added to each of the canvas items created in the call (some **dui add** calls create
not one but several items).

4. DUI itself adds several tags to the list:

  -One `p:<page_name>` tag per page in which the item appears. This is internally used to locate items in pages, find out which ones to show when a page has to be shown, etc.
	
  -One common `<main_tag>*` tag to all canvas items created in the call. This is useful for control "compounds", such as an entry and its label; a listbox, its label and its crollbars; or each line, rectangle, oval, and text items used to create canvas-based controls such as rounded-rectangle buttons or dsliders. Using this notation, all individual items in a compound can be shown, hidden, enabled, disabled, recolored or moved at once using calls like **dui item enable espresso pressure_chart*** while still retaining the possibility of accessing and modifying each of the invididual elements.
  
  -For Tk widgets, the widget pathname is added as a tag, to allow "reverse searching" from pathnames to canvas IDs.

<a name="items_api"></a>

#### Visual items API

<a name="dui_item"></a>

#### `dui item`

The **dui item** ensemble includes most commands to deal with visual GUI elements, except those dealing with creating the items and adding them to pages. Because the **dui add** are so often used, the shorthand **dui add** is offered (yet **dui item add** also works).

The following commands form the exported API of `dui item`, but the ensemble includes a good number of extra commands that are not exported but can still be accessed using fully qualified calls such as **::dui::item::relocate_txt_wrt**. These are normally only used internally by other DUI procs, but may on occasion be useful for client code too, for example if it builds its own sets of compound widgets. Their usage is documented in the source code.


<a name="dui_item_add"></a>

**dui item add**  _type ?subtype? page x y ?option option_value...?_

>Same as the equivalent **dui add** call.


<a name="dui_item_get"></a>

**dui item get**  _ids_or_widgets_

**dui item get**  _page tags_

>Return the unique canvas IDs of the requested items. If only one argument is given, it is interpreted as either a list of canvas IDs or a list of widget pathnames. In both cases, the same values are returned after validation, i.e. only if they correspond to existing objects. While this form may not seem very useful, it is provided mainly to be used from other commands that may receive either an element of the *widgets* page namespace array, or a page+tag combination.

>The two-arguments call is more commonly used by final code, and return the  _unique_  canvas IDs of the items matching  _tags_  in the requested  _page_ . If  _page_  is a list with several pages, only the first one is used. Add "*" to a main tag name to return all the items in a widget compound. Use `all` or an empty string as  _tags_  to return the IDs of all the page elements.


<a name="dui_item_get_widget"></a>

**dui item get_widget**  _ids_or_widgets_

**dui item get_widget**  _page tags_

>Return unique valid widget pathnames corresponding to the provided canvas IDs, widget pathnames, or page and tags combinations.


<a name="dui_item_pages"></a>

**dui item pages**  _page_or_id_or_widget ?tag?_

>Return a list of the pages in which the item referred to by  _page_or_id_or_widget_  and (optionally)  _tag_  appears.


<a name="dui_item_config"></a>

**dui item config**  _page_or_ids_or_widgets ?tags? option value ?option value ...?_

>Modify the configuration options of the canvas item or widget. 
Items are selected in the same way as in **dui item get**.
If it is a widget, the options are passed to the widget configure command, if it is a canvas item the options are passed to the canvas itemconfig command. 
>You can also modify the DUI-specific option  _-initial_state_ .


<a name="dui_item_cget"></a>

**dui item cget**  _page_or_ids_or_widgets ?tags? option_

>Return the current value of the configuration option for the specified canvas item or widget.
Items are selected in the same way as in **dui item get**.
Option may have any of the values accepted by the create widget command if it is a widget, or by the canvas create item
command if it is a canvas item.
>You can also query the DUI-specific option  _-initial_state_ .

<a name="dui_item_enable_or_disable"></a>

**dui item enable**  _page_or_ids_or_widgets ?tags? ?-option value ...?_

**dui item disable**  _page_or_ids_or_widgets ?tags? ?-option value ...?_

**dui item enable_or_disable**  _enabled page_or_ids_or_widgets ?tags? ?-option value ...?_

>Enable or disable the specified canvas items or widgets. 
Items are selected in the same way as in **dui item get**. Add a "*" suffix to a main tag to enable or disable all the items in a widget compound at once.
_enabled_ can be any value that is coerced to a boolean (1/0, true/false, etc.)

>**-current**  _boolean_

>>If **-current** is  _true_ , enables or disables the item immediately. Default value is  _true_ .

>**-initial**  _boolean_

>>If **-initial** is  _true_ , permanently modifies the initial enabled/disabled state of the item, that is, whether is is shown enabled (normal) or disabled whenever its page is shown. Default value is  _false_ .



<a name="dui_item_show_or_hide"></a>

**dui item show**  _page_or_ids_or_widgets ?tags? ?-option value ...?_

**dui item hide**  _page_or_ids_or_widgets ?tags? ?-option value ...?_

**dui item show_or_hide**  _show page_or_ids_or_widgets ?tags? ?-option value ...?_

>Show or hide the specified canvas items or widgets. 
Items are selected in the same way as in **dui item get**. Add a "*" suffix to a main tag to show or hide all the items in a widget compound at once. By default show or hides items only in the currently active page, and does nothing if the item does not appear in the current page. Showing or hiding by default also only affects the current state of the widget, but does not affect its initial state (how it will appears the next time a page that includes the item is shown). Use the  **-initial**  option to alter the initial state.

> _show_  is coerced to a boolean (takes any value accepted by `string is true`, such as 1/0, true/false, yes/no, on/off, etc.)

>**-check_page**  _boolean_

>>If **-check_page** is  _true_  and **-current** is also  _true_ , only changes the state if the item appears in the currently active page. Default value is  _true_ . If you change state in an **after** command, this prevents the item appearing in the wrong page (if the user changes page in the midtime).

>**-current**  _boolean_

>>If **-current** is  _true_ , shows or hides the item immediately (but only if it appears in the currently active page when **-check_page** is  _true_ ). Default value is  _true_ .

>**-initial**  _boolean_

>>If **-initial** is  _true_ , permanently modifies the initial show/hide state of the item, that is, whether is is shown or hidden whenever its page is shown. Default value is  _false_ .


<a name="dui_item_moveto"></a>

**dui item moveto**  _page_or_id_or_widget tag x y_

>Moves items to a new screen location.  _x_  and  _y_  give the new top-left coordinates. If  _tag_  selects all items in a compound (ends with a "*" character), all individual items of the compound will be moved, preserving their relative positions (use this to move, for example, dbuttons).


<a name="dui_item_listbox_get_selection"></a>

**dui item listbox_get_selection**  _page_or_id_or_widget ?tag values?_

>Gets the selected items from the specified listbox widget. If  _values_  is specified, the return string is looked up in the  _values_  list instead of the values in the listbox itself (using the same indexes). If the  _values_  list is shorter than the actual list of values being shown in the listbox and the selected item cannot be matched in  _values_ , return the matching string from the listbox values.


<a name="dui_item_listbox_set_selection"></a>

**dui item listbox_set_selection**  _page_or_id_or_widget tag selected ?values reset_current?_

>Selects the items matching the  _selected_  string in the specified listbox widget. If a  _values_  list is provided,  _selected_  is matched against  _values_  instead of the list values. If  _reset_current_  is 1 (or any other value that is coerced to a boolean  _true_ ), the current selection is reset first (this is only relevant with listboxes that accept multiple selections).


<a name="dui_add"></a>

#### `dui add`

##### Common options

A few **dui add** commands just offer convenience shorthands to other commands, such as **dui add theme** or **dui add page**, but most procs are used to add GUI elements to pages. All those share a number of options that are listed here instead of listing them for every command.

**pages**

>A list with the pages where the item will be shown. The pages must have been declared previously using  **dui page add**. Note that adding an item to several pages does not duplicate the item. Only one instance of each visual item will be created, and that instance will be shown or hidden as relevant for the current visible page.

<a name="dui_coordinates"></a>

**{coords}**

>The **x** and **y** coordinates where the item must be placed. Some items like canvas lines or rectangles may take additional coordinates. 
>The coordinates can be given in two ways:

>1. If their value is zero or greater or equal to 1, they are interpreted as relative locations with respect to the page top-left
coordinate in a 2650x1600 pixels space, and are mapped internally to the actual resolution in use. In standard pages that
occupy the full screen, the top-left coordinate is always {0 0}, but dialog pages are smaller than the screen and can be
positioned anywhere, so the coordinates in that case are relative to the dialog top-left position.

>2. If their value is greater than 0 and smaller than 1, they are interpreted as percentages of the available width or height,
that is the width or height of the page they are placed in.

>Note that canvas items and widgets must be placed in fixed locations, unlike other geometry managers like [grid](https://www.tcl.tk/man/tcl8.6/TkCmd/grid.htm). While this works great in most DE1 app pages, it's not ideal under some circunstances. Most notable is when using text-based data input, as the dimensions of entries or listboxes widgets are defined in number of characters (which are font-dependent) and not in pixels, and other widgets must be placed on their right or bottom sides. A few workarounds for these cases are:
>1. Use pixel instead of character dimensions, using the **-canvas_width** and **-canvas_height** options instead of the **-width** and **-height** options of widgets like entries and listboxes.
>2. Reposition items relative to others dynamically, using procs such as the (non exported) **::dui::item::relocate_text_wrt** or **::dui::item::set_yscrollbar_dim**. Because the actual dimensions of items are not accessible until the page is painted for the first time, these must be called on the page **show** command or **show** event action.
>3. Create a Tk frame inside the canvas and manage its geometry with **grid** or other geometry manager.

**-tags**  _tag_list_

>Tags are essential for accessing and modifying GUI elements after they are created. The first tag in  _tag_list_  uniquely identifies the item (or set of items if it's a  _compound_ ). It is required to be unique  _per page_ , and can only have letters, numbers and underscores. There are no restrictions on the rest of tags in the list (except those imposed by the canvas itself). In addition to the tags defined in the **dui add** call, DUI adds some tags of its own to identify item compounds and the pages in which each item appears.

>If page namespaces are used, the first (=main) tag is used as the key in the **widgets** and **data** namespace array variables. **$::&lt;page_namespace&gt;::data(&lt;main_tag&gt;)** is also used (and auto initialized) as default variable for widgets that take a global variable name (such as entries, listboxes, scales, etc.), when the variable is not explicitly defined in the call.

**-variable**  _variable_name_

**-textvariable**  _variable_name_

**-listvariable**  _variable_name_

>Name of the global variable whose value will be shown in the widget. Editing in the widget modifies the variable value, and if the variable value changes anywhere, then the widget will automatically update itself to reflect the new value.

>If not specified in the call and a page namespace is used, uses `::<page_namespace>::data(<main_tag>)`.

>If a plain name is given (only letters, numbers and underscores) and a page namespace is used, uses `::<page_namespace>::data(<textvariable>)`.

>If the text **%NS** is found in the variable name and a page namespace is used, it is substituted by the page namespace.

**-theme**  _theme_

>The [theme](#aspects) used to get the default values for the creation options ("aspects") that are not directly specified in the call. This is normally not used, as by default the currently active theme is used, but may be used exceptionally to format some pages using a theme different from the one in use.

>Use the special value "**none**" as  _theme_  to not apply any aspects to the visual item.


**-style**  _style_

>The [style](#aspects) used to get default values for the creation options ("aspects") that are not directly specified in the call. Styles are used to have different visual aspects or "versions" of the same item type, for example, to have different types of buttons (with different colors, sizes, or positioning of the inside label and icon)

**-font_family**  _family_

**-font_size**  _size_

**-font_weight**  _normal_or_bold_

**-font_slant**  _roman_or_italic_

**-font_underline**  _true_or_false_

**-font_overstrike**  _true_or_false_

>All elements that use text will accept this set of individual font options. Note that without DUI these cannot be passed individually to creation commands but must be embedded in the **-font** option. DUI allows you to specify each one individually so that most can be taken from the theme/type/style and the client code can modify only one or a few of them when needed.

>Font sizes can be  _relative_ . If  _size_  is a number prefixed by "-" or "+", the size will be decreased or increased with respect to the default theme/type/style font size.

**-canvas_***option*** **  _value_

>When creating Tk widgets with a **dui add** command, most options are passed through to the widget **create** command. The set of  **-canvas_* ** options serve to pass some options to the **canvas create** command instead. This is useful, for example, to override the width and height in characters of text-based widgets and use pixel sizes instead (e.g. **-canvas_width 200 -canvas_height 450**) or to change the default "nw" anchoring (e.g. **-canvas_anchor center**).

**-tclcode**  _tcl_code_

>For Tk widgets, Tcl code that will be evaluated after the widget is created, for example to allow configuring the widget. Note that this is evaluated in the **dui add** proc local context, not in the global context.

>The following substitutions are available:

> >-**%W**: Substituted by the widget pathname.

> >-**%NS**: Substituted by the page namespace, is one is used, or an empty string otherwise.

> _DESIGN NOTE_ : This is maintained at the moment for backwards compatibility, but evaluating this code in the creation proc context seems pretty unsafe, as it can modify any local variable. Given that DUI provides the mechanisms to easily access the created widgets once they're created, maintaining this doesn't seem really necessary.

**-initial_state**  _state_

>This is used to define what should be the initial state of the item  _whenever the page is shown_ . Normally not needed, as it defaults to  _normal_  and most page elements are shown when showing the page. Useful when some items may be hidden or disabled depending of the situation, because it is better to hide or disable them initially and then conditionally show or enable them than doing the reverse (which was the only option before DUI) to avoid the flickering effect of something appearing and rapidly disappearing from the page.

**-label_** _option_   _value_

**-symbol_** _option_   _value_

**-yscrollbar_** _option_   _value_

>When a **dui add** command creates a control  _compound_ , use the corresponding prefix on the option names to pass those options to the "sub-item" creation command.

##### Synonym "convenience" commands

**dui add theme**  _theme_name ?theme_name ...?_

>A synonym of **dui theme add**, included for convenience.

**dui add aspect**  _?-option value ...?  aspect value  ?aspect value ...?_

>A synonym of **dui aspect set**, included for convenience.

**dui add symbol**  _symbol_name unicode ?symbol_name unicode ...?

>A synonym of **dui symbol set**, included for convenience.

**dui add page**  _page_name ?-option value ...?_

>A synonym of **dui page add**, included for convenience.

**dui add font**  _args_

>A synonym of **dui font load**, included for convenience.

**dui add font_dirs**  _directory ?directory ...?_

>A synonym of **dui font add_dirs**, included for convenience.

**dui add image_dirs**  _directory ?directory ...?_

>A synonym of **dui image add_dirs**, included for convenience.

##### Commands to add GUI elements

<a name="dui_add_canvas_item"></a>

**dui add canvas_item**  _type pages x y ?{extra_coords}? ?-option value ...?_

>Generic command to add canvas items of type  _type_  to DUI pages. Some canvas items like **text** or **image** have their own **dui add** command with extra features, but this is offered for extensions and for adding items such as lines or ovals that don't have their own **dui add** command.


<a name="dui_add_widget"></a>

**dui add widget**  _type pages x y ?-option value ...?_

>Generic command to create Tk widgets of type  _type_  and add them to DUI pages. Many widgets like **entry** or **listbox** have their own **dui add** command with extra features, but this is offered for extensions and other non directly supported widgets.


<a name="dui_add_dtext"></a>

**dui add dtext**  _pages x y ?-option value ...?_

>Create a text label and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>Non-DUI options are passed-through to [canvas create text](https://www.tcl-lang.org/man/tcl/TkCmd/canvas.htm#M156).

>**-command**  _true_or_false_or_tcl_code_

> >Runs  _tcl_code_  when the text is clicked. If 1 or true or yes, and a page namespace command exists with the same name as the main tag, it will the command invoked. If it is a plain name (letters, numbers and underscores only) and the name matches a namespace command, it will be the command invoked.


<a name="dui_add_variable"></a>

**dui add variable**  _pages x y ?-option value ...?_

>Create a text label whose contents are updated dynamically and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>Non-DUI options are passed-through to [canvas create text](https://www.tcl-lang.org/man/tcl/TkCmd/canvas.htm#M156).

>**-textvariable**  _tcl_code_

> >Callback Tcl code that returns the string to be shown. This will be evaluated continuously while the page is shown and on the idle state, updating the text whenever the result of the evaluation changes. If the page has a namespace and  _tcl_code_  is a plain name (only letters, numbers and underscores, no brackets etc.), or if no **-textvariable** is provided at all (in this case the main tag will be used), then the callback will be `{$::<page_namespace>::data(<tcl_code_or_main_tag>)}`.

> >You can use `%NS` anywhere in  _tcl_code_  and it will be substituted by the page namespace.

>**-command**  _true_or_false_or_tcl_code_

> >Runs  _tcl_code_  when the text is clicked. If 1 or true or yes, and a page namespace command exists with the same name as the main tag, it will the command invoked. If it is a plain name (letters, numbers and underscores only) and the name matches a namespace command, it will be the command invoked.

> >In addition to standard substitutions, **%NS** is substituted by the page namespace.

<a name="dui_add_image"></a>

**dui add image**  _pages x y filename ?-option value ...?_

>Create an image from a file and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>If  _filename_  doesn't specify the full path, the image is searched for sequentially in subfolder &lt;screen_size_width&gt;x&lt;screen_size_height&gt; of each of the image directories added with **dui add image_dirs** until a match is found. If not found, it is then searched in the subfolder for the base screen resolution &lt;1280x1600&gt; and, if found, rescaled on the fly to the target screen resolution. The rescaled image is saved so next time it is just read from disk.

>Non-DUI options are passed-through to [image create](https://www.tcl-lang.org/man/tcl/TkCmd/image.htm). The default image type is **photo**.

>Images are loaded only once to reduce memory usage. A dictionary is kept with the normalized path of every loaded image so that, if it is added again to the canvas, the already loaded image is used. 

>Images are actually loaded from their files either at setup time or at page load time (the first time a page that contains the image is shown). Use the second option to reduce app startup time. This is controlled by the DUI configuration setting **preload_images**.

<a name="dui_add_shape"></a>

**dui add shape**  _shape pages x y ?x1 y1? ?-option value ...?_

>Create a canvas shape and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x y}_ . 
>These shapes can be ovals, rectangles or rounded-corners rectangles, and are normally used to enclose other elements
like buttons or dialog pages.
>  _shape_  can take any of the following values:

> >-**rect**: A rectangle. This accepts as formatting options those taken by **canvas create rect**.

> >-**oval**: An oval. This accepts as formatting options those taken by **canvas create oval**.

> >-**round**: A rounded-corners filled rectangle. This type of button cannot have a border (outline). It is the type of buttons used in the Metric and MimojaCafe skins. It accepts as formatting options **-fill** (button fill color), **-disabledfill** (button fill color when disabled) and **-radius** (determines how "round" the rectangle corners are).

>> **radius** can be a list of up to 4 elements, giving the radius of each of the 4 corners separately, starting top-left and going clockwards {top-left top-right bottom-right bottom-left}. If it has less than 4 elements, they are replicated until having 4 elements. A radius of 0 draws a 90º angle.

> >-**outline**: A rounded-corners rectangle with a visible outline border. In this case, the fill color is that of the background, and cannot be modified. This is the type of button used in the DSx skin. It accepts as formatting options **-outline** (color of the outline), **-disabledoutline** (color of the outline when the button is disabled), **-arc_offset** (determines how "round" the rectangle corners are) and **-width** (line width of the outline border). When using DUI styles it may sometimes be necessary to explicitly set **-fill {}** so it's not inherited from parent (such as "dbutton") defaults.

> >-**round_outline**: A rounded-corners rectangle with a visible outline border which, unlike **outline**, can be filled with a color different from the background. This is actually built overlapping a "round" shape and an "outline" shape. It accepts as formatting options **-fill** (fill color), **-disabledfill** (fill color when disabled), **-outline** (color of the outline), **-disabledoutline** (color of the outline when the shape is disabled), **-radius** (determines how "round" the rectangle corners are) and **-width** (line width of the outline border).

>> **arc_offset** can be a list of up to 4 elements, giving the radius of each of the 4 corners separately, starting top-left and going clockwards {top-left top-right bottom-right bottom-left}. If it has less than 4 elements, they are replicated until having 4 elements. A radius of 0 draws a 90º angle.


>Return a list with the canvas IDs of all the canvas items that conform the shape.

<a name="dui_add_dbutton"></a>

**dui add dbutton**  _pages x y ?x1 y1? ?-option value ...?_

>Create a "dui button" (a rectangular "clickable" area) from canvas primitive shapes and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x y}_ . 

>The button background can be invisible (if no options are provided) or it can have different shapes depending on the **-shape** option. 

>Return the list of all canvas IDs that form the button compound. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;: the invisible "clickable" rectangle;

> >&lt;main_tag&gt;-btn: the background button shape, which may itself be composed of several canvas items such as lines, rectangles and ovals; For `-shape round_outline`, this is the background rounded rectangle.

> >&lt;main_tag&gt;-out: the round button outline shape when `-shape round_outline` is used. It is itself composed of several canvas lines and arcs.

> >&lt;main_tag&gt;-lbl, &lt;main_tag&gt;-lbl1, etc.: (optional) label text;

> >&lt;main_tag&gt;-sym, &lt;main_tag&gt;-sym1, etc.: (optional) symbol text.

> >&lt;main_tag&gt;-img, &lt;main_tag&gt;-img1, etc.: (optional) image.

>During development, especially with invisible background buttons, you may want to set the global DUI configuration variable **debug_buttons** to 1 using `dui config debug_buttons 1`, as this will make the clickable area visible by drawing the button border. If the default black color of this border is not visible against the theme background, you can change it by modifying the **debug_outline** dbutton aspect (i.e. `dui aspect set -type dbutton debug_outline yellow`).

>**-bwidth**  _width_

>**-bheight**  _height_

> >Normally button dimensions are defined giving the rectangle top-left [coordinates](#dui_coordinates)  _{x y}_  and bottom-down coordinates  _{x1 y1}_ , but  _{x1 y1}_  can be replaced by named options **-bwidth** and **-bheight**. This is most often used for defining a dbutton style for buttons that are always the same size.  _width_  and  _height_  must be pixel sizes in a 2560x1600 screen, and they are transformed automatically to the actual resolution.

>**-anchor**  _anchor_value_

> >If  _x1_  and  _y1_  are not defined (so, **-bwidth** and **-bheight** are used),  _anchor_value_  defines the alignment of the dbutton with respect to the coordinates  _{x y}_ . Anchor valid values are "center", "n", "ne", ""nw", "s", "se", "sw", "w", and "e". Default is "nw" (i.e.  _{x y}_  are the top-left coordinates).

>**-shape**  _shape_

> >Shape determines how the background button should be painted. It can be an empty string (for no background / 
invisible clickable area) or any of the shape values accepted by [dui add shape](#dui_add_shape).

>**-command**  _tcl_code_
> >Callback Tcl code to run when the button is clicked. When the page has a namesapce, if a plain name is used (only letters, numbers and underscores) and the namespace has a command with that name, it is used. If not specified and the page namespace has a command with the same number as the main tag, it is used.

> >In addition to the standard substitutions, DUI adds the following:

> >**%NS**: The page namespace, if defined.

> >**%x0, %y0, %x1, %y1**: top-left and botton-right [coordinates](#dui_coordinates) of the button rectangle.

>**-longpress_cmd**  _tcl_code_
> >Callback Tcl code to run when the button receives a long press. When the page has a namesapce, if a plain name is used (only letters, numbers and underscores) and the namespace has a command with that name, it is used. If not specified and the page namespace has a command with the same number as the main tag, it is used.

> >In addition to the standard substitutions, DUI adds the following:

> >**%NS**: The page namespace, if defined.

> >**%x0, %y0, %x1, %y1**: top-left and botton-right [coordinates](#dui_coordinates) of the button rectangle.

>**-label**  _text_

>**-labelvariable**  _tcl_code_

>**-label&lt;i&gt;**  _text_

>**-label&lt;i&gt;variable**  _tcl_code_

> >If **-label** or **-labelvariable** are used, adds a fixed or dynamic text label, respectively, inside the button. 

> >As many labels as desired can be added, by using **-label1**, **-label1variable**, **-label2**, etc.

>**-label_pos**  _{horizontal_percentage vertical_percentage}_

>**-label&lt;i&gt;_pos**  _{horizontal_percentage vertical_percentage}_

> >Determines the location of the label inside the button rectangle, given by horizontal and vertical percentages. For example, for placing a label in the center of the button, use `-label_pos {0.5 0.5}` (and, probably, also `-label_anchor center`).

>**-label_***option*** **  _value_

>**-label&lt;i&gt;_***option*** **  _value_

> >Use this syntax to pass additional options to the label creation command. They will be passed through to either **dui add dtext** if **-label** was used, or to **dui add variable** if **-labelvariable** was used.

>**-symbol**  _symbol_name_

>**-symbol&lt;i&gt;**  _symbol_name_

> >Place a Fontawesome symbol inside the button. As many symbols as desired can be added, by using **-symbol1**, **-symbol2**, etc.

>**-symbol_pos**  _{horizontal_percentage vertical_percentage}_

>**-symbol&lt;i&gt;_pos**  _{horizontal_percentage vertical_percentage}_

> >Determines the location of the symbol inside the button rectangle, given by horizontal and vertical percentages. For example, for placing a symbol on the left side of the button, use `-symbol_pos {0.15 0.5}` (and, probably, also `-symbol_anchor center`).

>**-symbol_***option*** **  _value_

>**-symbol&lt;i&gt;_***option*** **  _value_

> >Use this syntax to pass additional options to the symbol creation command **dui add symbol**.

>**-image**  _filename_

>**-image&lt;i&gt;**  _filename_

> >Place an image inside the button. As many images as desired can be added, by using **-image1**, **-image2**, etc.

>**-image_pos**  _{horizontal_percentage vertical_percentage}_

>**-image&lt;i&gt;_pos**  _{horizontal_percentage vertical_percentage}_

> >Determines the location of the image inside the button rectangle, given by horizontal and vertical percentages.

>**-image_***option*** **  _value_

>**-image&lt;i&gt;_***option*** **  _value_

> >Use this syntax to pass additional options to the image creation command **dui add image**.

>**-tap_pad**  _{padding0 ?padding1? ?padding2? ?padding3?}_

> >A list with up to 4 distances that increase the tapping area in each of the 4 directions  _{left top right bottom}_ . The padding distances are replicated if less than 4 values are provided: if the list only has one value, it is used in the 4 directions. If it has 2 values, the first applies to both left and right (horizontal) and the second to top and bottom (vertical). It it has 3 values, the first value is reused for the bottom..


**dui add dclicker**  _pages x y ?x1 y1? ?-option value ...?_

>Create a special "dui button" that allows to increase and decrease a numeric variable by clicking on the extremes of the button. It can have horizontal (default) or vertical orientation, it can use one (small) or two (small and big) types of increments, and it can use any type of text, symbol or image for the increment and decrement actions.

>Return the list of all canvas IDs that form the button compound. Accepts the same named options as **dui add dbutton** plus the following ones:

>**-orient**  _horizontal_or_vertical_

> >Whether to divide the button in vertical "clickable" areas/slides (if **-orient** is  _horizontal_ , the default), or in horizontal ones (if **-orient** is  _vertical_ ).

>**-n_decimals**  _number_

> >The number of decimal places to use when formatting the number.

>**-min**  _number_

> >The minimum value of the variable.

>**-max**  _number_

> >The maximum value of the variable.

>**-use_biginc**  _true_or_false_

> >Boolean (1/0, true/false, yes/no, on/off) that determines whether "big increment" will be used in the button. Note that, even if **-use_biginc** is  _true_ , you should provide **-bigincrement** if a page editor is going to be used.

>**-smallincrement**  _number_

> >Small increment value.

>**-bigincrement**  _number_

> >Big increment value.

>**-default**  _number_

> >Default value to assign the first time the button is clicked if the variable value is empty. 

>**-editor_page**  _true_or_false_or_page_

> >If  _true_  or the name of a page, a full page number editor will be launched when the entry receives a double-click. If  _true_  (or any equivalent value such as 1, yes, etc.) is given, the default number editor page that comes with DUI (`dui_number_editor`) will be used. If  _false_ , no page editor will be used. If this is not specified in the call, the default value is taken from the DUI configuration variable **use_editors_pages**.

> >The editor page will receive all necessary parameters (-variable, -n_decimals, -min, -max, -smallincrement, -bigincrement, -default and -page_title). If a custom number editor page is used, it needs to have the same argument signature as ``::dui::pages::dui_number_editor::load``.

>**-editor_page_title**  _title_

> >The page title to show on the editor page.


<a name="dui_add_dselector"></a>

**dui add dselector**  _pages x y ?x1 y1? ?-option value ...?_

>Create a set of buttons shown together in a row or column that allow selecting one or several options,.

>Return the list of all canvas IDs that form the button compound. 

>**-orient**  _horizontal_or_vertical_

> >Whether to show as a row ( _horizontal_ , the default) or as a column ( _vertical_ ) of buttons.

>**-multiple**  _boolean_

> >If 0/false/no/off (the default case), the target value can have a single value, and only one button in the row or column can be active at each time. If 1/true/yes/on, the target value is a list (whose elements can be in any order) with the set of items that are active in the dselector.

>**-variable**  _variable_name_

> >Name of the global variable whose value will be shown in the control. It is a list with multiple elements if `-multiple` is 1. Tapping on the dselector buttons modifies the variable value, and if the variable value changes anywhere, then the dselector will automatically update itself to reflect the new value.

> >If not specified and a page namespace is used, uses `::<page_namespace>::data(<main_tag>)`.

> >If a plain name is given (only letters, numbers and underscores) and a page namespace is used, uses ``::<page_namespace>::data(<textvariable>)`.

> >**%NS** in  _variable_name_  will be substituted by the page namespace, or an empty string if no page namespace is used.

>**-values**  _list_of_possible_values_

> >A list with the possible values that  _variable_  can take.

>**-lengths**  _lengths_specification_

> >A list with the same length as  _values_ , giving a specification of the length of each button, as interpreted by [dui::page::split_space](#dui_page_split_space). _length_  is the button width if orientation is horizontal, or height if the orientation is vertical. If not defined, each button has the same length.

>**-command**  _tcl_code_

> >Runs  _tcl_code_  when any of the buttons is clicked. If 1 or true or yes, and a page namespace command exists with the same name as the main tag, it will the command invoked. If it is a plain name (letters, numbers and underscores only) and the name matches a namespace command, it will be the command invoked. The following substitutions are performed in  _tcl_code_  :
)
> >-**%NS**: Substituted by the page namespace, is one is used, or an empty string otherwise.

> >-**%V**: Substituted by the list of possible values.

> >-**%v**: Substituted by the tapped value.

> >-**%m**: Substituted by 0 or 1, depeding on the value of the  _-multiple_  option.

> >-**%x0**, **%x1**, **%y0**, **%y1**: Bounding box coordinates of the tapped button.

>**-labels**  _list_of_labels_

> >An optional list with the same length as  _values_ , providing the label text for each dbutton in the dselector.

>**-symbols**  _list_of_symbols_

> >An optional list with the same length as  _values_ , providing a symbol for each dbutton in the dselector.

>**-fill**  _color_

> >Background fill color for non-selected dbuttons.

>**-selectedfill**  _color_

> >Background fill color for selected dbuttons.

>**-outline**  _color_

> >Fill color of the outline border line of non-selected dbuttons.

>**-selectedoutline**  _color_

> >Fill color of the outline border line of selected dbuttons.

>**-label_fill**  _color_

> >Font fill color of the labels of non-selected dbuttons.

>**-label_selectedfill**  _color_

> >Font fill color of the labels of selected dbuttons.

>**-symbol_fill**  _color_

> >Font fill color of the symbols of non-selected dbuttons.

>**-symbol_selectedfill**  _color_

> >Font fill color of the symbols of selected dbuttons.

>All additional arguments in  _args_  are passed through to each of the individual [dui::add::dbutton](#dui_add_dbutton) calls.


<a name="dui_add_dtoggle"></a>

**dui add dtoggle**  _pages x y ?x1 y1? ?-option value ...?_

>Create a toggle switch button that allows defining a boolean variable. A visually more modern version of the [dcheckbox](#dui_add_dcheckbox).
>Return the canvas IDs of the clickable area. Accepts the same named options as **dui add dbutton** plus the following ones:

>**-width**  _width_

>**-height**  _height_

> >Normally bounding box dimensions are defined giving the rectangle top-left [coordinates](#dui_coordinates)  _{x y}_  and bottom-down coordinates  _{x1 y1}_ , but  _{x1 y1}_  can be replaced by named options **-width** and **-height**.  _width_  and  _height_  must be pixel sizes in a 2560x1600 screen, and they are transformed automatically to the actual resolution.

>**-anchor**  _anchor_value_

> >If  _x1_  and  _y1_  are not defined (so, **-width** and **-height** are used),  _anchor_value_  defines the alignment of the toggle bounding box with respect to the coordinates  _{x y}_ . Anchor valid values are "center", "n", "ne", ""nw", "s", "se", "sw", "w", and "e". Default is "nw" (i.e.  _{x y}_  are the top-left coordinates).


>**-sliderwidth**  _width_

> >Width of the inner circle, in pixels in a 2560x1600 space, transformed automatically to the actual resolution.

>**-variable**  _variable_name_

> >Name of the global boolean variable whose value will be shown in the control. Tapping on the dtoggle button modifies the variable value, and if the variable value changes anywhere, then the dtoggle will automatically update itself to reflect the new value.

> >If not specified and a page namespace is used, uses `::<page_namespace>::data(<main_tag>)`.

> >If a plain name is given (only letters, numbers and underscores) and a page namespace is used, uses ``::<page_namespace>::data(<textvariable>)`.

> >**%NS** in  _variable_name_  will be substituted by the page namespace, or an empty string if no page namespace is used.

>**-foreground**  _color_

> >Fill color of the slider circle when the value is  _false_ .

>**-selectedforeground**  _color_

> >Fill color of the slider circle when the value is  _true_ .

>**-disabledforeground**  _color_

> >Fill color of the slider circle when the widget is disabled.

>**-outline_width**  _width_

> >Width in pixels (in the 2560x1800 base space) of the slider circle outline. Use zero for not drawing an outline.

>**-outline**  _color_

> >Fill color of the slider circle outline when the value is  _false_ .

>**-selectedoutline**  _color_

> >Fill color of the slider circle outline when the value is  _true_ .

>**-disabledoutline**  _color_

> >Fill color of the slider circle outline when the widget is disabled.

>**-background**  _color_

> >Fill color of the background rounded rectangle when the value is  _false_ .

>**-selectedbackground**  _color_

> >Fill color of the background rounded rectangle when the value is  _true_ .

>**-disabledbackground**  _color_

> >Fill color of the background rounded rectangle when the widget is disabled.


<a name="dui_add_entry"></a>

**dui add entry**  _pages x y ?-option value ...?_

>Create a text entry Tk widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>Return the pathname of the entry widget. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;: the entry widget.

> >&lt;main_tag&gt;-lbl: (optional) the canvas ID of the label text.

>Non-DUI options are passed-through to the [entry](https://www.tcl.tk/man/tcl8.6/TkCmd/entry.htm) command.

>**-data_type**  _data_type_

> >Define the data type. Only useful value at the moment is "numeric", though more types will be supported in the future. If the  _data_type_  is numeric and a validation command **-vcmd** is not provided in the call, validation is automatically added using the values of options **-n_decimals**, **-min**, and **-max**.

>**-n_decimals**  _number_

> >For `-data type numeric`, the number of decimal places to use when formatting the number.

>**-min**  _number_

> >For `-data type numeric`, the minimum value of the variable.

>**-max**  _number_

> >For `-data type numeric`, the maximum value of the variable.

>**-smallincrement**  _number_

> >For `-data type numeric`, small increment used on associated clicker or scale controls. Not used directly, but passed to page editors if the **-editor_page** option is specified

>**-bigincrement**  _number_

> >For `-data type numeric`, big increment used on associated clicker or scale controls. Not used directly, but passed to page editors if the **-editor_page** option is specified

>**-default**  _number_

> >For `-data type numeric`, default value to assign the first time a clicker is clicked if the variable value is empty. Not used directly, but passed to page editors if the **-editor_page** option is specified

>**-trim**  _true_or_false_

> >If true, trims leading and trailing whitespace after the user edits the value. Default is taken from the value of DUI configuration variable **trim_entries**.

>**-editor_page**  _true_or_false_or_page_

> >If  _true_  or the name of a page, a full page number editor will be launched when the entry receives a double-click. If  _true_  (or any equivalent value such as 1, yes, etc.) is given, the default number editor page that comes with DUI (`dui_number_editor`) will be used. If  _false_ , no page editor will be used. If this is not specified in the call, the default value is taken from the DUI configuration variable **use_editors_pages**.

> >The editor page will receive all necessary parameters (-variable, -n_decimals, -min, -max, -smallincrement, -bigincrement, -default and -page_title). If a custom number editor page is used, it needs to have the same argument signature as ``::dui::pages::dui_number_editor::load``.

>**-editor_page_title**  _title_

> >The page title to show on the editor page.

>**-label**  _text_

>**-labelvariable**  _tcl_code_

> >If **-label** or **-labelvariable** are used, adds a fixed or dynamic text label, respectively, associated to the entry.

>**-label_pos**  _{x y}_

>**-label_pos**  _{anchor ?x_offset? ?y_offset?}_

> >A list that determines the location of the label. If a pair of numeric coordinates are provided, they are interpreted as direct coordinates in the screen. If the first list item is not a number, it is interpreted as an anchor point relative to the edges of the entry widget, and the label will be moved to the target position when the page is shown. 

> >Valid anchor values are "n", "nw", "ne", "s", "sw", "se", "w", "wn", "ws", "e", "en", "es". To get the label placed exactly as you want you normally also have to play with **-label_anchor** and **-label_justify**.

> >The anchor value can optionally be followed by an  _x_offset_  and a  _y_offset_ , which will move the position by those fixed offsets after the anchor point is determined.

>**-label_***option*** **  _value_

> >Use this syntax to pass additional options to the label creation command. They will be passed through to either **dui add dtext** if **-label** was used, or to **dui add variable** if **-labelvariable** was used.


<a name="dui_add_multiline_entry"></a>

**dui add multiline_entry**  _pages x y ?-option value ...?_

>Create a multiline text entry Tk widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>The multiline entry widget is [a simplified version of the text widget](https://wiki.tcl-lang.org/page/Multi-Line+Entry+Widget+in+Snit).

>Return the pathname of the text widget. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;: the multiline_entry widget.

> >&lt;main_tag&gt;-ysb: (optional) the pathname of the yscrollbar scale.

> >&lt;main_tag&gt;-lbl: (optional) the canvas ID of the label text.

>Non-DUI options are passed-through to the [text](https://www.tcl.tk/man/tcl8.4/TkCmd/text.htm) command.

>**-data_type**  _data_type_

> >Define the data type. Only useful value at the moment is "numeric", though more types will be supported in the future. If the  _data_type_  is numeric and a validation command **-vcmd** is not provided in the call, validation is automatically added using the values of options **-n_decimals**, **-min**, and **-max**.

>**-label**  _text_

>**-labelvariable**  _tcl_code_

> >If **-label** or **-labelvariable** are used, adds a fixed or dynamic text label, respectively, associated to the entry.

>**-label_pos**  _{x y}_

>**-label_pos**  _{anchor ?x_offset? ?y_offset?}_

> >A list that determines the location of the label. If a pair of numeric coordinates are provided, they are interpreted as direct coordinates in the screen. If the first list item is not a number, it is interpreted as an anchor point relative to the edges of the entry widget, and the label will be moved to the target position when the page is shown. 

> >Valid anchor values are "n", "nw", "ne", "s", "sw", "se", "w", "wn", "ws", "e", "en", "es". To get the label placed exactly as you want you normally also have to play with **-label_anchor** and **-label_justify**.

> >The anchor value can optionally be followed by an  _x_offset_  and a  _y_offset_ , which will move the position by those fixed offsets after the anchor point is determined.

>**-label_***option*** **  _value_

> >Use this syntax to pass additional options to the label creation command. They will be passed through to either **dui add dtext** if **-label** was used, or to **dui add variable** if **-labelvariable** was used.

>**-yscrollbar**  _true_or_false_

> >If  _true_ , a vertical scrollbar is added to the right side of the listbox. The scrollbar is actually a Tk scale widget, not a Tk scrollbar widget. 

>**-yscrollbar_***option*** **  _value_

> >Use this syntax to pass additional options to the yscrollbar scale creation command.


<a name="dui_add_text"></a>

**dui add text**  _pages x y ?-option value ...?_

>Create a Tk text widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>Return the pathname of the Text widget. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;: the Text widget.

> >&lt;main_tag&gt;-lbl: (optional) the canvas ID of the label text.

> >&lt;main_tag&gt;-ysb: (optional) the Tk scale widget used as vertical scrollbar.

>Non-DUI options are passed-through to the Tk [text](https://www.tcl.tk/man/tcl8.6/TkCmd/text.htm) command.

>**-label**  _text_

>**-labelvariable**  _tcl_code_

> >If **-label** or **-labelvariable** are used, adds a fixed or dynamic text label, respectively, associated to the text widget.

>**-label_pos**  _{x y}_

>**-label_pos**  _{anchor ?x_offset? ?y_offset?}_

> >A list that determines the location of the label. If a pair of numeric coordinates are provided, they are interpreted as direct coordinates in the screen. If the first list item is not a number, it is interpreted as an anchor point relative to the edges of the listbox widget, and the label will be moved to the target position when the page is shown. 

> >Valid anchor values are "n", "nw", "ne", "s", "sw", "se", "w", "wn", "ws", "e", "en", "es". To get the label placed exactly as you want you normally also have to play with **-label_anchor** and **-label_justify**.

> >The anchor value can optionally be followed by an  _x_offset_  and a  _y_offset_ , which will move the position by those fixed offsets after the anchor point is determined.

>**-label_***option*** **  _value_

> >Use this syntax to pass additional options to the label creation command. They will be passed through to either **dui add dtext** if **-label** was used, or to **dui add variable** if **-labelvariable** was used.

>**-yscrollbar**  _true_or_false_

> >If  _true_ , a vertical scrollbar is added to the right side of the text widget. The scrollbar is actually a Tk scale widget, not a Tk scrollbar widget. 

>**-yscrollbar_***option*** **  _value_

> >Use this syntax to pass additional options to the yscrollbar scale creation command.


<a name="dui_add_listbox"></a>

**dui add listbox**  _pages x y ?-option value ...?_

>Create a listbox Tk widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>Return the pathname of the listbox widget. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;: the listbox widget.

> >&lt;main_tag&gt;-lbl: (optional) the canvas ID of the label text.

> >&lt;main_tag&gt;-ysb: (optional) the Tk scale widget used as vertical scrollbar.

>Non-DUI options are passed-through to the [listbox](https://www.tcl.tk/man/tcl8.6/TkCmd/listbox.htm) command.

>**-label**  _text_

>**-labelvariable**  _tcl_code_

> >If **-label** or **-labelvariable** are used, adds a fixed or dynamic text label, respectively, associated to the listbox.

>**-label_pos**  _{x y}_

>**-label_pos**  _{anchor ?x_offset? ?y_offset?}_

> >A list that determines the location of the label. If a pair of numeric coordinates are provided, they are interpreted as direct coordinates in the screen. If the first list item is not a number, it is interpreted as an anchor point relative to the edges of the listbox widget, and the label will be moved to the target position when the page is shown. 

> >Valid anchor values are "n", "nw", "ne", "s", "sw", "se", "w", "wn", "ws", "e", "en", "es". To get the label placed exactly as you want you normally also have to play with **-label_anchor** and **-label_justify**.

> >The anchor value can optionally be followed by an  _x_offset_  and a  _y_offset_ , which will move the position by those fixed offsets after the anchor point is determined.

>**-label_***option*** **  _value_

> >Use this syntax to pass additional options to the label creation command. They will be passed through to either **dui add dtext** if **-label** was used, or to **dui add variable** if **-labelvariable** was used.

>**-yscrollbar**  _true_or_false_

> >If  _true_ , a vertical scrollbar is added to the right side of the listbox. The scrollbar is actually a Tk scale widget, not a Tk scrollbar widget. 

>**-yscrollbar_***option*** **  _value_

> >Use this syntax to pass additional options to the yscrollbar scale creation command.

>**-select_cmd**  _tcl_code_

> >Code to run when a row in the listbox is selected. If it is a plain name (letters, numbers and underscores only) and the name matches a namespace command, it will be the command invoked. Substitutions **%W** and **%NS** are done on the code.

<a name="dui_add_dcheckbox"></a>

**dui add dcheckbox**  _pages x y ?-option value ...?_

>Create a "dui checkbox" widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x y}_ . 

>This widget consists of a Fontawesome symbol variable with the actual clickable checkbox plus a text label. 

>The advantage over a Tk checkbox is that the fontawesome symbol can scale to any size and has a flat aspect, whereas the Tk checkbox has a fixed size that looks tiny in most tablet screens.

>Return the canvas ID of the checkbox symbols text. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;: the checkbox symbol text.

> >&lt;main_tag&gt;-lbl: (optional) the canvas ID of the label text.

>Non-DUI options are passed-through to the [canvas create text](https://www.tcl-lang.org/man/tcl/TkCmd/canvas.htm#M156) command.

>**-texvariable**  _variable_name_

> >Name of the global variable whose value will be shown in the checkbox. Clicking the checkbox modifies the variable value, and if the variable value changes anywhere, then the checkbox will automatically update itself to reflect the new value.

> >If not specified and a page namespace is used, uses `::<page_namespace>::data(<main_tag>)`.

> >If a plain name is given (only letters, numbers and underscores) and a page namespace is used, uses ``::<page_namespace>::data(<textvariable>)`.

>**-command**  _tcl_code_

> >Optional callback code to run when the checkbox is clicked.
> >In addition to the usual substituttions, **%NS** will be replaced by the page namespace name, or the empty string if no page namespace is used.


<a name="dui_add_scale"></a>

**dui add scale**  _pages x y ?-option value ...?_

>Create a Tk scale widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>Non-DUI options are passed-through to the [scale create](https://www.tcl-lang.org/man/tcl/TkCmd/scale.htm) command.


<a name="dui_add_dscale"></a>

**dui add dscale**  _pages x y ?-option value ...?_

>Create a "dui scale" widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>This scale offers a more modern looking aspect than Tk scales, and is built using canvas primitives (lines, circles and text). Most of its options receive the same names as the Tk scale widget options, though **-n_decimals** is used instead of **-digits**.

>Return the list of all canvas IDs that form the scale compound. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;-crc: the slider circle;

> >&lt;main_tag&gt;-bck: the background line;

> >&lt;main_tag&gt;-frn: the foregroundline;

> >&lt;main_tag&gt;-tap: the "clickable" rectangle covering the background;

> >&lt;main_tag&gt;-inc: the plus sign;

> >&lt;main_tag&gt;-tinc: the "clickable" rectangle over the plus sign;

> >&lt;main_tag&gt;-dec: the minus sign;

> >&lt;main_tag&gt;-tdec: the "clickable" rectangle over the minus sign;

> >&lt;main_tag&gt;-lbl: (optional) label text;


>**-orient**  _horizontal_or_vertical_

> >Orientation of the scale. Defaults to horizontal. Actually only the first character is used.

>**-variable**  _variable_name_

> >Name of the global variable whose value will be shown in the dscale. Editing the scale modifies the variable value, and if the variable value changes anywhere, then the scale slider will automatically update itself to reflect the new value.

> >If not specified and a page namespace is used, uses `::<page_namespace>::data(<main_tag>)`.

> >If a plain name is given (only letters, numbers and underscores) and a page namespace is used, uses ``::<page_namespace>::data(<textvariable>)`.

> >**%NS** in  _variable_name_  will be substituted by the page namespace, or an empty string if no page namespace is used.

>**-length**  _length_

> >Total horizontal or vertical distance of the background line of the scale, in pixels in a 2560x1600 space that will be transformed to the actual resolution.

>**-width**  _width_

> >Width of the background and foreground scale lines, in pixels in a 2560x1600 space that will be transformed to the actual resolution.

>**-sliderlength**  _length_

> >Width and height or the slider circle, in pixels in a 2560x1600 space that will be transformed to the actual resolution.

>**-from**  _number_

> >The minimum accepted value of the variable.

>**-to**  _number_

> >The maximum accepted value of the variable.

>**-foreground**  _color_

> >The fill color of the foreground scale line (the part of the line that marks the variable value, i.e. the left section in horizontal scales, and the bottom section in vertical scales), and the slider circle, when the control is enabled.

>**-activeforeground**  _color_

> >The fill color of the slider circle when it is active (i.e. when it is tapped for moving it).

>**-disabledforeground**  _color_

> >The fill color of the foreground scale line and the slider circle when the control is disabled.

>**-background**  _color_

> >The fill color of the background line when the control is enabled.

>**-disabledbackground**  _color_

> >The fill color of the background line when the control is disabled.

>**-resolution**  _number_

> >The minimum step size. Default is 1 (integers).

>**-n_decimals**  _integer_

> >Number of decimals to use when formatting the number values. Default is 0.

>**-smallincrement**  _number_

> >Passed to the full page number editor, and used when tapping the plus/minus. Default  the same value as **-resolution**, if not specified.

>**-bigincrement**  _number_

> >Passed to the full page number editor, and used when tapping repeteadly the plus/minus (currently implemented as triple-click, but may change).

>**-plus_minus**  _true_or_false_

> >Whether to show (default) or hide the plus and minus on the line extremes. Tapping the plus or minus symbols increases/reduces the variable value by  _smallincrement_ . Tapping them fast three times increases/reduces the variable value by  _bigincrement_ .

>**-default**  _number_

> >Default value when the variable is empty. This is normally used only by the page editor to assign an initial value if the variable is the empty string.

>**-editor_page**  _true_or_false_or_page_

> >If  _true_  or the name of a page, a full page number editor will be launched when the scale label is clicked. If  _true_  (or any equivalent value such as 1, yes, etc.), the default number editor page that comes with DUI (`dui_number_editor`) will be used. If  _false_ , no page editor will be used. If this is not specified in the call, the default value is taken from the DUI configuration variable **use_editors_pages**.

> >The editor page will receive all necessary parameters (-variable, -n_decimals, -min, -max, -smallincrement, -bigincrement, -default and -page_title). If a custom number editor page is used, it needs to have the same argument signature as ``::dui::pages::dui_number_editor::load``.

>**-editor_page_title**  _title_

> >The page title to show on the editor page.


<a name="dui_add_drater"></a>

**dui add drater**  _pages x y ?-option value ...?_

>Create a "dui rater" widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . 

>The "drater" allows to rate something by assining it a number of stars (or other symbol). It can map to any integer variable, and allows as an option to use half-stars.

>Return the list of all canvas IDs that form the "drater" compound. The command also adds (if applicable) the following named tags to the canvas, and the same keys in the widgets page namespace array: 

> >&lt;main_tag&gt;: the "clickable" rectangle bounding all star symbols;

> >&lt;main_tag&gt;-&lt;number&gt;: each of the star symbols;

> >&lt;main_tag&gt;-h&lt;number&gt;: (optional) each of the half star symbols;

> >&lt;main_tag&gt;-lbl: (optional) label text;

>**-variable**  _variable_name_

> >Name of the global variable whose value will be shown in the drater. Clicking on the stars modifies the variable value, and if the variable value changes anywhere, then the active stars update to reflect the new value.

> >If not specified and a page namespace is used, uses `::<page_namespace>::data(<main_tag>)`.

> >If a plain name is given (only letters, numbers and underscores) and a page namespace is used, uses ``::<page_namespace>::data(<variable>)`.

> >**%NS** in  _variable_name_  will be substituted by the page namespace, or an empty string if no page namespace is used.

>**-width**  _length_

> >Total horizontal distance occupied by the drater, in pixels in a 2560x1600 space, will be transformed to the actual resolution.

>**-n_ratings**  _integer_

> >The number of stars to show.

>**-use_halfs**  _true_or_false_

> >Whether to use half stars. Default is  _true_ .

>**-min**  _integer_

> >The minimum accepted value of the variable.

>**-max**  _integer_

> >The maximum accepted value of the variable.

>**-fill**  _color_

> >The fill color of the stars when they are active (to show that the rating is achieved).

>**-disabledfill**  _color_

> >The fill color of the stars when they are inactive (to show that the rating is not achieved).


<a name="dui_add_graph"></a>

**dui add graph**  _pages x y ?-option value ...?_

>Create a BLT graph widget and add it to the requested  _pages_  at [coordinates](#dui_coordinates)  _{x, y}_ . Returns the created command name. Non-DUI options are passed-through to the [BLT graph](http://blt.sourceforge.net/) command.

>Most configuration of BLT graphs is not done in the **dui add graph** command, but through subcommands of the created widget, so you need to get the reference to the graph widget. This is returned from the call, can be retrieved by DUI using the page and tag, or, if using page namespaces, from the `widgets` namespace array. Like this:

```tcl
set widget [dui add graph <pages> <x> <y> -background ....]
$widget axis configure ...
$widget element create ...
```

>or 

```tcl
dui add graph <pages> <x> <y> -tags mygraph ...
(...)
set widget [dui item get_widget <page> mygraph]
$widget axis configure ...
$widget element create ...
```

>One tricky part of graphs is how to apply DUI styling to elements like axis or lines that are not created in the **dui add graph** call but afterwards. The **-as_options yes** argument of **dui aspect list** is intended for these cases, and can be applied as follows:

```tcl
$widget element create line_history_left_chart -xdata <xdata> -ydata <ydata> \
    {*}[dui aspect list -type graph_line -style hv_line -as_options yes]
```
