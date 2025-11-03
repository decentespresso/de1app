To create a profile_editor, add a new directory within this /profile_editor/ directory with the name of whatever you want to name your new editor

The directory name is automatically used as the namespace for each profile editor.
Although you can use a hyphen"-" in the directory name, variables taking on the ::namespace::variable would then have a "-", the de1app -textvariable doesn't handle "-" well.
There are work arounds, but it is easier to just use an undescore instead.

Preference is given to button a command that declars an editor eg: "show_profile_editor declair_editor"
If the button doesn't declare a profile_editor eg: "show_profile_editor {}", the profile is checked for a "profile_editor" setting.
If there is no profile_editor setting matching and existing editor, the original editors are loaded

You can have any files and/or folders you like within your profile editors directory.
All and only .tcl files in the top directory will auto join at boot up.

Your editor code should include the following proc
proc show_editor { args } {
    your_code_to_run_when_opening_your_profile_editor
}

The page_name for your editor page can be whatever you like, but it needs to be unique
to your profile_editor to prevent conflicts with other pages. A good way to ensure that
is to use your editors name as part of the page name
In my demo editor, I use "demo_editor_page" for my page name

You don't need to create or set up a page, you can just add page items, although you can and/or config the page background colour if you like.

Your editor_page will need a button/s to exit back to the app, you can of cause customise the cammands however you like,
or use on of the following simplified options form new procs in ../skins/default/de1_skin_settings.tcl
button -command options
        exit_profile_editor {presets}   go to Presets page
        exit_profile_editor {app}       go to Presets page
        exit_profile_editor {machine}   go to Presets page
        exit_profile_editor {save}      go to off page, runs the original settings pages save button commands
        exit_profile_editor {ok}        go to off page, runs the original settings pages save button commands
        exit_profile_editor {cancel}    go to off page, runs the original settings pages cancel botton commands
        exit_profile_editor {}          go to off page, using "set_next_page off off; page_show off"


I have included a "demo" profile editor with a file "test.tcl which has some sample code

Your .tcl pages are checked prior to joining. If they return an error they will not be joined and the app will load with out showing the error.
You can search the log.txt file for "profile_editor" or you editor name to see if your files loaded ok or any error they returned.
