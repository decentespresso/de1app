package provide de1_misc 1.0

proc make_de1_dir {srcdir destdirs} {
    set files {
        binary.tcl *
        bluetooth.tcl *
        translation.tcl *
        de1plus.tcl *
        de1.tcl *
        de1app.tcl *
        de1_comms.tcl *
        gui.tcl *
        history_viewer.tcl *
        dui.tcl *
        metadata.tcl *
        app_metadata.tcl *
        machine.tcl *
        utils.tcl *
        main.tcl *
        plugins.tcl *
        vars.tcl *
        de1_comms.tcl *
        updater.tcl *
        logging.tcl *
        misc.tcl *
        pkgIndex.tcl *
        de1_icon_v2.png *
        de1plus_icon_v2.png *
        cloud_download_icon.png *
        create_de1app_icon.tcl *
        create_de1plus_icon.tcl *
        create_de1_update_icon.tcl *
        appupdate.tcl *
        cline_appupdate.tcl *
        autopair_with_de1.tcl *
        autopair_with_de1plus.tcl *
        history_export.tcl *
        version.tcl *
        profile.tcl *
        shot.tcl *
        de1_de1.tcl *
        device_scale.tcl *
        event.tcl *

        build-info.txt *

        profiles_v2/readme.txt *

        history/info.txt *
        history/export/readme.txt *

        history_v2/readme.txt *

        fw/bootfwupdate.dat *
        wallpaper/spy_1280x800.jpg *
        wallpaper/spy_2560x1600.jpg *
        sounds/KeypressStandard_120.ogg *
        sounds/KeypressDelete_120.ogg *

        "fonts/Font Awesome 5 Brands-Regular-400.otf" *
        "fonts/Font Awesome 5 Duotone-Solid-900.otf" *
        "fonts/Font Awesome 5 Pro-Light-300.otf" *
        "fonts/Font Awesome 5 Pro-Regular-400.otf" *
        "fonts/Font Awesome 5 Pro-Solid-900.otf" *

        fonts/NotoSansCJKjp-Bold.otf *
        fonts/NotoSansCJKjp-Regular.otf *
        fonts/notosansuibold.ttf *
        fonts/notosansuiregular.ttf *
        fonts/sarabun.ttf *
        fonts/hebrew-regular.ttf *
        fonts/hebrew-bold.ttf *
        fonts/sarabunbold.ttf *
        fonts/Dubai-Bold.otf *
        fonts/Dubai-Regular.otf *

        godshots/none.shot *
        godshots/import/readme.txt *
        godshots/import/common/readme.txt *
        godshots/export/readme.txt *
        godshots/export/common/readme.txt *
        godshots/export/columnar/readme.txt *

        splash/1280x800/de1.jpg *
        splash/2560x1600/de1.jpg *

        skins/default/de1_skin_settings.tcl *
        skins/default/skin.tcl *
        skins/default/standard_includes.tcl *
        skins/default/standard_stop_buttons.tcl *

        skins/default/1280x800/nothing_on.png *
        skins/default/1280x800/firmware_upgrade.jpg *
        skins/default/1280x800/firmware_upgrade_on.jpg *
        skins/default/1280x800/firmware_upgrade_off.jpg *
        skins/default/1280x800/espresso_on.png *
        skins/default/1280x800/steam_on.png *
        skins/default/1280x800/tea_on.png *
        skins/default/1280x800/sleep.jpg *
        skins/default/1280x800/filling_tank.jpg *
        skins/default/1280x800/fill_tank.jpg *
        skins/default/1280x800/cleaning.jpg *
        skins/default/1280x800/settings_message.png  *
        skins/default/1280x800/settings_3_choices.png  *
        skins/default/1280x800/ghc.jpg *
        skins/default/1280x800/descale_prepare.jpg *
        skins/default/1280x800/descaling.jpg *
        skins/default/1280x800/settings_1.png *
        skins/default/1280x800/settings_2.png *
        skins/default/1280x800/settings_2a.png *
        skins/default/1280x800/settings_2a2.png *
        skins/default/1280x800/settings_2b.png *
        skins/default/1280x800/settings_2b2.png *
        skins/default/1280x800/settings_2c.png *
        skins/default/1280x800/settings_2c2.png *
        skins/default/1280x800/settings_3.png *
        skins/default/1280x800/settings_4.png *
        skins/default/1280x800/icon.jpg *
        skins/default/1280x800/travel_do.jpg *
        skins/default/1280x800/travel_prepare.jpg *
        skins/default/1280x800/descalewarning.jpg *

        skins/default/2560x1600/firmware_upgrade.jpg *
        skins/default/2560x1600/firmware_upgrade_on.jpg *
        skins/default/2560x1600/firmware_upgrade_off.jpg *
        skins/default/2560x1600/nothing_on.png *
        skins/default/2560x1600/espresso_on.png *
        skins/default/2560x1600/steam_on.png *
        skins/default/2560x1600/tea_on.png *
        skins/default/2560x1600/sleep.jpg *
        skins/default/2560x1600/filling_tank.jpg *
        skins/default/2560x1600/fill_tank.jpg *
        skins/default/2560x1600/cleaning.jpg *
        skins/default/2560x1600/settings_message.png  *
        skins/default/2560x1600/settings_3_choices.png  *
        skins/default/2560x1600/ghc.jpg *
        skins/default/2560x1600/descale_prepare.jpg *
        skins/default/2560x1600/descaling.jpg *
        skins/default/2560x1600/settings_1.png *
        skins/default/2560x1600/settings_2.png *
        skins/default/2560x1600/settings_2a.png *
        skins/default/2560x1600/settings_2a2.png *
        skins/default/2560x1600/settings_2b.png *
        skins/default/2560x1600/settings_2b2.png *
        skins/default/2560x1600/settings_2c.png *
        skins/default/2560x1600/settings_2c2.png *
        skins/default/2560x1600/settings_3.png *
        skins/default/2560x1600/settings_4.png *
        skins/default/2560x1600/icon.jpg *
        skins/default/2560x1600/travel_do.jpg *
        skins/default/2560x1600/travel_prepare.jpg *
        skins/default/2560x1600/descalewarning.jpg *

        skins/Antibes/skin.tcl *
        skins/Antibes/moonflower.ttf *
        skins/Antibes/1280x800/espresso_on.png *
        skins/Antibes/1280x800/icon.jpg *
        skins/Antibes/1280x800/nothing_on.png *
        skins/Antibes/1280x800/steam_on.png *
        skins/Antibes/1280x800/tea_on.png *
        skins/Antibes/2560x1600/espresso_on.png *
        skins/Antibes/2560x1600/icon.jpg *
        skins/Antibes/2560x1600/nothing_on.png *
        skins/Antibes/2560x1600/steam_on.png *
        skins/Antibes/2560x1600/tea_on.png *

        skins/SWDark4/screen_saver/2560x1600/saver-1.jpg *
        skins/SWDark4/screen_saver/2560x1600/saver-2.jpg *
        skins/SWDark4/screen_saver/2560x1600/saver-3.jpg *
        skins/SWDark4/screen_saver/1280x800/saver-1.jpg *
        skins/SWDark4/screen_saver/1280x800/saver-2.jpg *
        skins/SWDark4/screen_saver/1280x800/saver-3.jpg *
        skins/SWDark4/swdark_functions.tcl *
        skins/SWDark4/skin.tcl *
        skins/SWDark4/img/hearticon.png *
        skins/SWDark4/helveticabold12.ttf *
        skins/SWDark4/helveticabold16.ttf *
        skins/SWDark4/helveticabold17.ttf *
        skins/SWDark4/helveticabold18.ttf *
        skins/SWDark4/helveticabold20.ttf *
        skins/SWDark4/helveticabold24.ttf *
        skins/SWDark4/2560x1600/home.png *
        skins/SWDark4/2560x1600/home_2.png *
        skins/SWDark4/2560x1600/home_2_single.png *
        skins/SWDark4/2560x1600/home_2_split.png *
        skins/SWDark4/2560x1600/swsettings.png *
        skins/SWDark4/2560x1600/icon.jpg *
        skins/SWDark4/2560x1600/sleep.png *
        skins/SWDark4/2560x1600/fill_tank.png *
        skins/SWDark4/2560x1600/saver-1.png *
        skins/SWDark4/2560x1600/saver-2.png *
        skins/SWDark4/2560x1600/saver-3.png *
        skins/SWDark4/2560x1600/swbrewsettings.png *
        skins/SWDark4/userdata/swdark_usersettings.tdb *
        skins/SWDark4/1280x800/icon.jpg *
        skins/SWDark4/1280x800/sleep.png *
        skins/SWDark4/1280x800/fill_tank.png *
        skins/SWDark4/1280x800/saver-1.png *
        skins/SWDark4/1280x800/saver-2.png *
        skins/SWDark4/1280x800/saver-3.png *
        skins/SWDark4/1280x800/home.png *
        skins/SWDark4/1280x800/home_2.png *
        skins/SWDark4/1280x800/home_2_single.png *
        skins/SWDark4/1280x800/home_2_split.png *
        skins/SWDark4/1280x800/swsettings.png *
        skins/SWDark4/1280x800/swbrewsettings.png *


        skins/Borg/skin.tcl *
        skins/Borg/diablo.ttf *
        skins/Borg/1280x800/espresso_on.png *
        skins/Borg/1280x800/icon.jpg *
        skins/Borg/1280x800/nothing_on.png *
        skins/Borg/1280x800/steam_on.png *
        skins/Borg/1280x800/tea_on.png *
        skins/Borg/2560x1600/espresso_on.png *
        skins/Borg/2560x1600/icon.jpg *
        skins/Borg/2560x1600/nothing_on.png *
        skins/Borg/2560x1600/steam_on.png *
        skins/Borg/2560x1600/tea_on.png *

        skins/Aztec/skin.tcl *
        skins/Aztec/aztec.ttf *
        skins/Aztec/1280x800/espresso_on.png *
        skins/Aztec/1280x800/icon.jpg *
        skins/Aztec/1280x800/nothing_on.png *
        skins/Aztec/1280x800/steam_on.png *
        skins/Aztec/1280x800/tea_on.png *
        skins/Aztec/2560x1600/espresso_on.png *
        skins/Aztec/2560x1600/icon.jpg *
        skins/Aztec/2560x1600/nothing_on.png *
        skins/Aztec/2560x1600/steam_on.png *
        skins/Aztec/2560x1600/tea_on.png *

        skins/Constructivism/skin.tcl *
        skins/Constructivism/orbitron.ttf *
        skins/Constructivism/1280x800/espresso_on.png *
        skins/Constructivism/1280x800/icon.jpg *
        skins/Constructivism/1280x800/nothing_on.png *
        skins/Constructivism/1280x800/steam_on.png *
        skins/Constructivism/1280x800/tea_on.png *
        skins/Constructivism/2560x1600/espresso_on.png *
        skins/Constructivism/2560x1600/icon.jpg *
        skins/Constructivism/2560x1600/nothing_on.png *
        skins/Constructivism/2560x1600/steam_on.png *
        skins/Constructivism/2560x1600/tea_on.png *

        skins/Roman\ Gods/skin.tcl *
        skins/Roman\ Gods/renaissance.ttf *
        skins/Roman\ Gods/1280x800/espresso_on.png *
        skins/Roman\ Gods/1280x800/icon.jpg *
        skins/Roman\ Gods/1280x800/nothing_on.png *
        skins/Roman\ Gods/1280x800/steam_on.png *
        skins/Roman\ Gods/1280x800/tea_on.png *
        skins/Roman\ Gods/2560x1600/espresso_on.png *
        skins/Roman\ Gods/2560x1600/icon.jpg *
        skins/Roman\ Gods/2560x1600/nothing_on.png *
        skins/Roman\ Gods/2560x1600/steam_on.png *
        skins/Roman\ Gods/2560x1600/tea_on.png *

        skins/8-BIT/skin.tcl *
        skins/8-BIT/pixel.ttf *
        skins/8-BIT/pixel2.ttf *
        skins/8-BIT/1280x800/espresso_on.png *
        skins/8-BIT/1280x800/espresso_on_plus.png *
        skins/8-BIT/1280x800/icon.jpg *
        skins/8-BIT/1280x800/nothing_on.png *
        skins/8-BIT/1280x800/steam_on.png *
        skins/8-BIT/1280x800/tea_on.png *
        skins/8-BIT/2560x1600/espresso_on.png *
        skins/8-BIT/2560x1600/espresso_on_plus.png *
        skins/8-BIT/2560x1600/icon.jpg *
        skins/8-BIT/2560x1600/nothing_on.png *
        skins/8-BIT/2560x1600/steam_on.png *
        skins/8-BIT/2560x1600/tea_on.png *

        skins/Teal\ Modern/skin.tcl *
        skins/Teal\ Modern/novocento.ttf *
        skins/Teal\ Modern/1280x800/espresso_on.png *
        skins/Teal\ Modern/1280x800/icon.jpg *
        skins/Teal\ Modern/1280x800/nothing_on.png *
        skins/Teal\ Modern/1280x800/steam_on.png *
        skins/Teal\ Modern/1280x800/tea_on.png *
        skins/Teal\ Modern/2560x1600/espresso_on.png *
        skins/Teal\ Modern/2560x1600/icon.jpg *
        skins/Teal\ Modern/2560x1600/nothing_on.png *
        skins/Teal\ Modern/2560x1600/steam_on.png *
        skins/Teal\ Modern/2560x1600/tea_on.png *

        skins/Green\ Cups/skin.tcl *
        skins/Green\ Cups/leaguegoth.ttf *
        skins/Green\ Cups/1280x800/espresso_on.png *
        skins/Green\ Cups/1280x800/icon.jpg *
        skins/Green\ Cups/1280x800/nothing_on.png *
        skins/Green\ Cups/1280x800/steam_on.png *
        skins/Green\ Cups/1280x800/tea_on.png *
        skins/Green\ Cups/2560x1600/espresso_on.png *
        skins/Green\ Cups/2560x1600/icon.jpg *
        skins/Green\ Cups/2560x1600/nothing_on.png *
        skins/Green\ Cups/2560x1600/steam_on.png *
        skins/Green\ Cups/2560x1600/tea_on.png *

        skins/Croissant/skin.tcl *
        skins/Croissant/1280x800/espresso_on.png *
        skins/Croissant/1280x800/icon.jpg *
        skins/Croissant/1280x800/nothing_on.png *
        skins/Croissant/1280x800/steam_on.png *
        skins/Croissant/1280x800/tea_on.png *
        skins/Croissant/2560x1600/espresso_on.png *
        skins/Croissant/2560x1600/icon.jpg *
        skins/Croissant/2560x1600/nothing_on.png *
        skins/Croissant/2560x1600/steam_on.png *
        skins/Croissant/2560x1600/tea_on.png *

        skins/Noir/skin.tcl *
        skins/Noir/1280x800/espresso_on.png *
        skins/Noir/1280x800/icon.jpg *
        skins/Noir/1280x800/nothing_on.png *
        skins/Noir/1280x800/steam_on.png *
        skins/Noir/1280x800/tea_on.png *
        skins/Noir/2560x1600/espresso_on.png *
        skins/Noir/2560x1600/icon.jpg *
        skins/Noir/2560x1600/nothing_on.png *
        skins/Noir/2560x1600/steam_on.png *
        skins/Noir/2560x1600/tea_on.png *

        skins/Three\ Women/skin.tcl *
        skins/Three\ Women/painthand.ttf *
        skins/Three\ Women/1280x800/espresso_on.png *
        skins/Three\ Women/1280x800/icon.jpg *
        skins/Three\ Women/1280x800/nothing_on.png *
        skins/Three\ Women/1280x800/steam_on.png *
        skins/Three\ Women/1280x800/tea_on.png *
        skins/Three\ Women/2560x1600/espresso_on.png *
        skins/Three\ Women/2560x1600/icon.jpg *
        skins/Three\ Women/2560x1600/nothing_on.png *
        skins/Three\ Women/2560x1600/steam_on.png *
        skins/Three\ Women/2560x1600/tea_on.png *

        skins/Rodent/skin.tcl *
        skins/Rodent/Heroes\ Legend.ttf *
        skins/Rodent/1280x800/espresso_on.png *
        skins/Rodent/1280x800/icon.jpg *
        skins/Rodent/1280x800/nothing_on.png *
        skins/Rodent/1280x800/steam_on.png *
        skins/Rodent/1280x800/tea_on.png *
        skins/Rodent/2560x1600/espresso_on.png *
        skins/Rodent/2560x1600/icon.jpg *
        skins/Rodent/2560x1600/nothing_on.png *
        skins/Rodent/2560x1600/steam_on.png *
        skins/Rodent/2560x1600/tea_on.png *

        skins/Diner/skin.tcl *
        skins/Diner/bellerose.ttf *
        skins/Diner/1280x800/espresso_on.png *
        skins/Diner/1280x800/icon.jpg *
        skins/Diner/1280x800/nothing_on.png *
        skins/Diner/1280x800/steam_on.png *
        skins/Diner/1280x800/tea_on.png *
        skins/Diner/2560x1600/espresso_on.png *
        skins/Diner/2560x1600/icon.jpg *
        skins/Diner/2560x1600/nothing_on.png *
        skins/Diner/2560x1600/steam_on.png *
        skins/Diner/2560x1600/tea_on.png *

        skins/Insight/1280x800/icon.jpg *
        skins/Insight/skin.tcl *
        skins/Insight/scentone.tcl *
        skins/Insight/1280x800/espresso_1.png *
        skins/Insight/1280x800/espresso_1_zoomed.png *
        skins/Insight/1280x800/espresso_2.png *
        skins/Insight/1280x800/espresso_2_zoomed.png *
        skins/Insight/1280x800/espresso_3.png *
        skins/Insight/1280x800/espresso_3_zoomed.png *
        skins/Insight/1280x800/steam_1.png *
        skins/Insight/1280x800/steam_2.png *
        skins/Insight/1280x800/steam_3.png *
        skins/Insight/1280x800/water_1.png *
        skins/Insight/1280x800/water_2.png *
        skins/Insight/1280x800/water_3.png *
        skins/Insight/1280x800/preheat_1.png *
        skins/Insight/1280x800/preheat_2.png *
        skins/Insight/1280x800/preheat_3.png *
        skins/Insight/1280x800/preheat_4.png *
        skins/Insight/1280x800/scentone_1.jpg *
        skins/Insight/1280x800/scentone_tropical.jpg *
        skins/Insight/1280x800/scentone_berry.jpg *
        skins/Insight/1280x800/scentone_citrus.jpg *
        skins/Insight/1280x800/scentone_stone.jpg *
        skins/Insight/1280x800/scentone_cereal.jpg *
        skins/Insight/1280x800/scentone_chocolate.jpg *
        skins/Insight/1280x800/scentone_flower.jpg *
        skins/Insight/1280x800/scentone_spice.jpg *
        skins/Insight/1280x800/scentone_vegetable.jpg *
        skins/Insight/1280x800/scentone_savory.jpg *
        skins/Insight/1280x800/describe_espresso0.jpg *
        skins/Insight/1280x800/describe_espresso.jpg *
        skins/Insight/1280x800/describe_espresso2.jpg *
        skins/Insight/2560x1600/icon.jpg *
        skins/Insight/2560x1600/espresso_1.png *
        skins/Insight/2560x1600/espresso_1_zoomed.png *
        skins/Insight/2560x1600/espresso_2.png *
        skins/Insight/2560x1600/espresso_2_zoomed.png *
        skins/Insight/2560x1600/espresso_3.png *
        skins/Insight/2560x1600/espresso_3_zoomed.png *
        skins/Insight/2560x1600/steam_1.png *
        skins/Insight/2560x1600/steam_2.png *
        skins/Insight/2560x1600/steam_3.png *
        skins/Insight/2560x1600/water_1.png *
        skins/Insight/2560x1600/water_2.png *
        skins/Insight/2560x1600/water_3.png *
        skins/Insight/2560x1600/preheat_1.png *
        skins/Insight/2560x1600/preheat_2.png *
        skins/Insight/2560x1600/preheat_3.png *
        skins/Insight/2560x1600/preheat_4.png *
        skins/Insight/2560x1600/scentone_1.jpg *
        skins/Insight/2560x1600/scentone_tropical.jpg *
        skins/Insight/2560x1600/scentone_berry.jpg *
        skins/Insight/2560x1600/scentone_citrus.jpg *
        skins/Insight/2560x1600/scentone_stone.jpg *
        skins/Insight/2560x1600/scentone_cereal.jpg *
        skins/Insight/2560x1600/scentone_chocolate.jpg *
        skins/Insight/2560x1600/scentone_flower.jpg *
        skins/Insight/2560x1600/scentone_spice.jpg *
        skins/Insight/2560x1600/scentone_vegetable.jpg *
        skins/Insight/2560x1600/scentone_savory.jpg *
        skins/Insight/2560x1600/describe_espresso0.jpg *
        skins/Insight/2560x1600/describe_espresso.jpg *
        skins/Insight/2560x1600/describe_espresso2.jpg *

        skins/Insight\ Dark/1280x800/icon.jpg *
        skins/Insight\ Dark/skin.tcl *
        skins/Insight\ Dark/1280x800/espresso_1.png *
        skins/Insight\ Dark/1280x800/espresso_1_zoomed.png *
        skins/Insight\ Dark/1280x800/espresso_2.png *
        skins/Insight\ Dark/1280x800/espresso_2_zoomed.png *
        skins/Insight\ Dark/1280x800/espresso_3.png *
        skins/Insight\ Dark/1280x800/espresso_3_zoomed.png *
        skins/Insight\ Dark/1280x800/steam_1.png *
        skins/Insight\ Dark/1280x800/steam_2.png *
        skins/Insight\ Dark/1280x800/steam_3.png *
        skins/Insight\ Dark/1280x800/water_1.png *
        skins/Insight\ Dark/1280x800/water_2.png *
        skins/Insight\ Dark/1280x800/water_3.png *
        skins/Insight\ Dark/1280x800/preheat_1.png *
        skins/Insight\ Dark/1280x800/preheat_2.png *
        skins/Insight\ Dark/1280x800/preheat_3.png *
        skins/Insight\ Dark/1280x800/preheat_4.png *
        skins/Insight\ Dark/1280x800/scentone_1.jpg *
        skins/Insight\ Dark/1280x800/scentone_tropical.jpg *
        skins/Insight\ Dark/1280x800/scentone_berry.jpg *
        skins/Insight\ Dark/1280x800/scentone_citrus.jpg *
        skins/Insight\ Dark/1280x800/scentone_stone.jpg *
        skins/Insight\ Dark/1280x800/scentone_cereal.jpg *
        skins/Insight\ Dark/1280x800/scentone_chocolate.jpg *
        skins/Insight\ Dark/1280x800/scentone_flower.jpg *
        skins/Insight\ Dark/1280x800/scentone_spice.jpg *
        skins/Insight\ Dark/1280x800/scentone_vegetable.jpg *
        skins/Insight\ Dark/1280x800/scentone_savory.jpg *
        skins/Insight\ Dark/1280x800/describe_espresso0.jpg *
        skins/Insight\ Dark/1280x800/describe_espresso.jpg *
        skins/Insight\ Dark/1280x800/describe_espresso2.jpg *
        skins/Insight\ Dark/2560x1600/icon.jpg *
        skins/Insight\ Dark/2560x1600/espresso_1.png *
        skins/Insight\ Dark/2560x1600/espresso_1_zoomed.png *
        skins/Insight\ Dark/2560x1600/espresso_2.png *
        skins/Insight\ Dark/2560x1600/espresso_2_zoomed.png *
        skins/Insight\ Dark/2560x1600/espresso_3.png *
        skins/Insight\ Dark/2560x1600/espresso_3_zoomed.png *
        skins/Insight\ Dark/2560x1600/steam_1.png *
        skins/Insight\ Dark/2560x1600/steam_2.png *
        skins/Insight\ Dark/2560x1600/steam_3.png *
        skins/Insight\ Dark/2560x1600/water_1.png *
        skins/Insight\ Dark/2560x1600/water_2.png *
        skins/Insight\ Dark/2560x1600/water_3.png *
        skins/Insight\ Dark/2560x1600/preheat_1.png *
        skins/Insight\ Dark/2560x1600/preheat_2.png *
        skins/Insight\ Dark/2560x1600/preheat_3.png *
        skins/Insight\ Dark/2560x1600/preheat_4.png *
        skins/Insight\ Dark/2560x1600/scentone_1.jpg *
        skins/Insight\ Dark/2560x1600/scentone_tropical.jpg *
        skins/Insight\ Dark/2560x1600/scentone_berry.jpg *
        skins/Insight\ Dark/2560x1600/scentone_citrus.jpg *
        skins/Insight\ Dark/2560x1600/scentone_stone.jpg *
        skins/Insight\ Dark/2560x1600/scentone_cereal.jpg *
        skins/Insight\ Dark/2560x1600/scentone_chocolate.jpg *
        skins/Insight\ Dark/2560x1600/scentone_flower.jpg *
        skins/Insight\ Dark/2560x1600/scentone_spice.jpg *
        skins/Insight\ Dark/2560x1600/scentone_vegetable.jpg *
        skins/Insight\ Dark/2560x1600/scentone_savory.jpg *
        skins/Insight\ Dark/2560x1600/describe_espresso0.jpg *
        skins/Insight\ Dark/2560x1600/describe_espresso.jpg *
        skins/Insight\ Dark/2560x1600/describe_espresso2.jpg *

        skins/DSx/1280x800/decent_logo.png *
        skins/DSx/1280x800/2SbuttonA.png *
        skins/DSx/1280x800/2SbuttonE.png *
        skins/DSx/1280x800/3SbuttonA.png *
        skins/DSx/1280x800/3SbuttonE.png *
        skins/DSx/1280x800/3SbuttonF.png *
        skins/DSx/1280x800/3SbuttonS.png *
        skins/DSx/1280x800/3SbuttonW.png *
        skins/DSx/1280x800/admin/cleanbutton.png *
        skins/DSx/1280x800/admin/cleanbuttonW.png *
        skins/DSx/1280x800/admin/tabover.png *
        skins/DSx/1280x800/big_scale.png *
        skins/DSx/1280x800/big_scale1.png *
        skins/DSx/1280x800/clock_bg.png *
        skins/DSx/1280x800/dial/cdeclb.png *
        skins/DSx/1280x800/dial/cdede.png *
        skins/DSx/1280x800/dial/cdedsv.png *
        skins/DSx/1280x800/dial/cdsvclb.png *
        skins/DSx/1280x800/dial/cdsvde.png *
        skins/DSx/1280x800/dial/cdsvdsv.png *
        skins/DSx/1280x800/dial/odeclb.png *
        skins/DSx/1280x800/dial/odede.png *
        skins/DSx/1280x800/dial/odedsv.png *
        skins/DSx/1280x800/dial/odsvclb.png *
        skins/DSx/1280x800/dial/odsvde.png *
        skins/DSx/1280x800/dial/odsvdsv.png *
        skins/DSx/1280x800/dial/rdeclb.png *
        skins/DSx/1280x800/dial/rdede.png *
        skins/DSx/1280x800/dial/rdedsv.png *
        skins/DSx/1280x800/dial/rdsvclb.png *
        skins/DSx/1280x800/dial/rdsvde.png *
        skins/DSx/1280x800/dial/rdsvdsv.png *
        skins/DSx/1280x800/icon.jpg *
        skins/DSx/1280x800/icons/arrow_left.png *
        skins/DSx/1280x800/icons/arrow_right.png *
        skins/DSx/1280x800/icons/bean.png *
        skins/DSx/1280x800/icons/bluecup.png *
        skins/DSx/1280x800/icons/button4.png *
        skins/DSx/1280x800/icons/button5.png *
        skins/DSx/1280x800/icons/button7.png *
        skins/DSx/1280x800/icons/button8.png *
        skins/DSx/1280x800/icons/click.png *
        skins/DSx/1280x800/icons/click1.png *
        skins/DSx/1280x800/icons/click_no_box.png *
        skins/DSx/1280x800/icons/DEespresso.png *
        skins/DSx/1280x800/icons/DEflush.png *
        skins/DSx/1280x800/icons/DEsteam.png *
        skins/DSx/1280x800/icons/DEwater.png *
        skins/DSx/1280x800/icons/espresso.png *
        skins/DSx/1280x800/icons/flush.png *
        skins/DSx/1280x800/icons/heart2.png *
        skins/DSx/1280x800/icons/history.png *
        skins/DSx/1280x800/icons/home.png *
        skins/DSx/1280x800/icons/jug.png *
        skins/DSx/1280x800/icons/jug_full.png *
        skins/DSx/1280x800/icons/niche.png *
        skins/DSx/1280x800/icons/niche1280.png *
        skins/DSx/1280x800/icons/orangecup.png *
        skins/DSx/1280x800/icons/people.png *
        skins/DSx/1280x800/icons/pinkcup.png *
        skins/DSx/1280x800/icons/power.png *
        skins/DSx/1280x800/icons/settings.png *
        skins/DSx/1280x800/icons/setup.png *
        skins/DSx/1280x800/icons/shift.png *
        skins/DSx/1280x800/icons/steam.png *
        skins/DSx/1280x800/icons/steam_timer.png *
        skins/DSx/1280x800/icons/stop.png *
        skins/DSx/1280x800/icons/store.png *
        skins/DSx/1280x800/icons/store_button.png *
        skins/DSx/1280x800/icons/water.png *
        skins/DSx/1280x800/icons/zoomminus.png *
        skins/DSx/1280x800/icons/zoomplus.png *
        skins/DSx/1280x800/icons/zoomshift.png *
        skins/DSx/1280x800/poweroff.png *
        skins/DSx/1280x800/SbuttonA.png *
        skins/DSx/1280x800/SbuttonE.png *
        skins/DSx/1280x800/SbuttonF.png *
        skins/DSx/1280x800/SbuttonS.png *
        skins/DSx/1280x800/SbuttonW.png *
        skins/DSx/1920x1200/decent_logo.png *
        skins/DSx/1920x1200/2SbuttonA.png *
        skins/DSx/1920x1200/2SbuttonE.png *
        skins/DSx/1920x1200/3SbuttonA.png *
        skins/DSx/1920x1200/3SbuttonE.png *
        skins/DSx/1920x1200/3SbuttonF.png *
        skins/DSx/1920x1200/3SbuttonS.png *
        skins/DSx/1920x1200/3SbuttonW.png *
        skins/DSx/1920x1200/admin/cleanbutton.png *
        skins/DSx/1920x1200/admin/cleanbuttonW.png *
        skins/DSx/1920x1200/admin/tabover.png *
        skins/DSx/1920x1200/big_scale.png *
        skins/DSx/1920x1200/big_scale1.png *
        skins/DSx/1920x1200/clock_bg.png *
        skins/DSx/1920x1200/dial/cdeclb.png *
        skins/DSx/1920x1200/dial/cdede.png *
        skins/DSx/1920x1200/dial/cdedsv.png *
        skins/DSx/1920x1200/dial/cdsvclb.png *
        skins/DSx/1920x1200/dial/cdsvde.png *
        skins/DSx/1920x1200/dial/cdsvdsv.png *
        skins/DSx/1920x1200/dial/odeclb.png *
        skins/DSx/1920x1200/dial/odede.png *
        skins/DSx/1920x1200/dial/odedsv.png *
        skins/DSx/1920x1200/dial/odsvclb.png *
        skins/DSx/1920x1200/dial/odsvde.png *
        skins/DSx/1920x1200/dial/odsvdsv.png *
        skins/DSx/1920x1200/dial/rdeclb.png *
        skins/DSx/1920x1200/dial/rdede.png *
        skins/DSx/1920x1200/dial/rdedsv.png *
        skins/DSx/1920x1200/dial/rdsvclb.png *
        skins/DSx/1920x1200/dial/rdsvde.png *
        skins/DSx/1920x1200/dial/rdsvdsv.png *
        skins/DSx/1920x1200/icon.jpg *
        skins/DSx/1920x1200/icons/arrow_left.png *
        skins/DSx/1920x1200/icons/arrow_right.png *
        skins/DSx/1920x1200/icons/bean.png *
        skins/DSx/1920x1200/icons/bluecup.png *
        skins/DSx/1920x1200/icons/button4.png *
        skins/DSx/1920x1200/icons/button5.png *
        skins/DSx/1920x1200/icons/button7.png *
        skins/DSx/1920x1200/icons/button8.png *
        skins/DSx/1920x1200/icons/click.png *
        skins/DSx/1920x1200/icons/click1.png *
        skins/DSx/1920x1200/icons/click_no_box.png *
        skins/DSx/1920x1200/icons/DEespresso.png *
        skins/DSx/1920x1200/icons/DEflush.png *
        skins/DSx/1920x1200/icons/DEsteam.png *
        skins/DSx/1920x1200/icons/DEwater.png *
        skins/DSx/1920x1200/icons/espresso.png *
        skins/DSx/1920x1200/icons/flush.png *
        skins/DSx/1920x1200/icons/heart2.png *
        skins/DSx/1920x1200/icons/history.png *
        skins/DSx/1920x1200/icons/home.png *
        skins/DSx/1920x1200/icons/jug.png *
        skins/DSx/1920x1200/icons/jug_full.png *
        skins/DSx/1920x1200/icons/niche.png *
        skins/DSx/1920x1200/icons/orangecup.png *
        skins/DSx/1920x1200/icons/people.png *
        skins/DSx/1920x1200/icons/pinkcup.png *
        skins/DSx/1920x1200/icons/power.png *
        skins/DSx/1920x1200/icons/settings.png *
        skins/DSx/1920x1200/icons/setup.png *
        skins/DSx/1920x1200/icons/shift.png *
        skins/DSx/1920x1200/icons/steam.png *
        skins/DSx/1920x1200/icons/steam_timer.png *
        skins/DSx/1920x1200/icons/stop.png *
        skins/DSx/1920x1200/icons/store.png *
        skins/DSx/1920x1200/icons/store_button.png *
        skins/DSx/1920x1200/icons/water.png *
        skins/DSx/1920x1200/icons/zoomminus.png *
        skins/DSx/1920x1200/icons/zoomplus.png *
        skins/DSx/1920x1200/icons/zoomshift.png *
        skins/DSx/1920x1200/poweroff.png *
        skins/DSx/1920x1200/SbuttonA.png *
        skins/DSx/1920x1200/SbuttonE.png *
        skins/DSx/1920x1200/SbuttonF.png *
        skins/DSx/1920x1200/SbuttonS.png *
        skins/DSx/1920x1200/SbuttonW.png *
        skins/DSx/2560x1600/decent_logo.png *
        skins/DSx/2560x1600/2SbuttonA.png *
        skins/DSx/2560x1600/2SbuttonE.png *
        skins/DSx/2560x1600/3SbuttonA.png *
        skins/DSx/2560x1600/3SbuttonE.png *
        skins/DSx/2560x1600/3SbuttonF.png *
        skins/DSx/2560x1600/3SbuttonS.png *
        skins/DSx/2560x1600/3SbuttonW.png *
        skins/DSx/2560x1600/admin/cleanbutton.png *
        skins/DSx/2560x1600/admin/cleanbuttonW.png *
        skins/DSx/2560x1600/admin/tabover.png *
        skins/DSx/2560x1600/big_scale.png *
        skins/DSx/2560x1600/big_scale1.png *
        skins/DSx/2560x1600/clock_bg.png *
        skins/DSx/2560x1600/dial/cdeclb.png *
        skins/DSx/2560x1600/dial/cdede.png *
        skins/DSx/2560x1600/dial/cdedsv.png *
        skins/DSx/2560x1600/dial/cdsvclb.png *
        skins/DSx/2560x1600/dial/cdsvde.png *
        skins/DSx/2560x1600/dial/cdsvdsv.png *
        skins/DSx/2560x1600/dial/odeclb.png *
        skins/DSx/2560x1600/dial/odede.png *
        skins/DSx/2560x1600/dial/odedsv.png *
        skins/DSx/2560x1600/dial/odsvclb.png *
        skins/DSx/2560x1600/dial/odsvde.png *
        skins/DSx/2560x1600/dial/odsvdsv.png *
        skins/DSx/2560x1600/dial/rdeclb.png *
        skins/DSx/2560x1600/dial/rdede.png *
        skins/DSx/2560x1600/dial/rdedsv.png *
        skins/DSx/2560x1600/dial/rdsvclb.png *
        skins/DSx/2560x1600/dial/rdsvde.png *
        skins/DSx/2560x1600/dial/rdsvdsv.png *
        skins/DSx/2560x1600/icon.jpg *
        skins/DSx/2560x1600/icons/arrow_left.png *
        skins/DSx/2560x1600/icons/arrow_right.png *
        skins/DSx/2560x1600/icons/bean.png *
        skins/DSx/2560x1600/icons/bluecup.png *
        skins/DSx/2560x1600/icons/button4.png *
        skins/DSx/2560x1600/icons/button5.png *
        skins/DSx/2560x1600/icons/button7.png *
        skins/DSx/2560x1600/icons/button8.png *
        skins/DSx/2560x1600/icons/click.png *
        skins/DSx/2560x1600/icons/click1.png *
        skins/DSx/2560x1600/icons/click_no_box.png *
        skins/DSx/2560x1600/icons/DEespresso.png *
        skins/DSx/2560x1600/icons/DEflush.png *
        skins/DSx/2560x1600/icons/DEsteam.png *
        skins/DSx/2560x1600/icons/DEwater.png *
        skins/DSx/2560x1600/icons/espresso.png *
        skins/DSx/2560x1600/icons/flush.png *
        skins/DSx/2560x1600/icons/heart2.png *
        skins/DSx/2560x1600/icons/history.png *
        skins/DSx/2560x1600/icons/home.png *
        skins/DSx/2560x1600/icons/jug.png *
        skins/DSx/2560x1600/icons/jug_full.png *
        skins/DSx/2560x1600/icons/niche.png *
        skins/DSx/2560x1600/icons/orangecup.png *
        skins/DSx/2560x1600/icons/people.png *
        skins/DSx/2560x1600/icons/pinkcup.png *
        skins/DSx/2560x1600/icons/power.png *
        skins/DSx/2560x1600/icons/settings.png *
        skins/DSx/2560x1600/icons/setup.png *
        skins/DSx/2560x1600/icons/shift.png *
        skins/DSx/2560x1600/icons/steam.png *
        skins/DSx/2560x1600/icons/steam_timer.png *
        skins/DSx/2560x1600/icons/stop.png *
        skins/DSx/2560x1600/icons/store.png *
        skins/DSx/2560x1600/icons/store_button.png *
        skins/DSx/2560x1600/icons/water.png *
        skins/DSx/2560x1600/icons/zoomminus.png *
        skins/DSx/2560x1600/icons/zoomplus.png *
        skins/DSx/2560x1600/icons/zoomshift.png *
        skins/DSx/2560x1600/poweroff.png *
        skins/DSx/2560x1600/SbuttonA.png *
        skins/DSx/2560x1600/SbuttonE.png *
        skins/DSx/2560x1600/SbuttonF.png *
        skins/DSx/2560x1600/SbuttonS.png *
        skins/DSx/2560x1600/SbuttonW.png *
        skins/DSx/DSx_Code_Files/DSx_functions.tcl *
        skins/DSx/DSx_Code_Files/DSx_skin.tcl *
        skins/DSx/DSx_Font_Files/alarm\ clock.ttf *
        skins/DSx/DSx_Font_Files/Bradley\ Hand\ Bold.ttf *
        skins/DSx/DSx_Font_Files/Comic\ Sans\ MS.ttf *
        skins/DSx/DSx_Font_Files/Font\ Awesome\ 5\ Brands-Regular-400.otf *
        skins/DSx/DSx_Font_Files/Font\ Awesome\ 5\ Duotone-Solid-900.otf *
        skins/DSx/DSx_Font_Files/Font\ Awesome\ 5\ Pro-Light-300.otf *
        skins/DSx/DSx_Font_Files/Font\ Awesome\ 5\ Pro-Regular-400.otf *
        skins/DSx/DSx_Font_Files/Font\ Awesome\ 5\ Pro-Solid-900.otf *
        skins/DSx/DSx_Font_Files/GochiHand-Regular.ttf *
        skins/DSx/DSx_Font_Files/Handlee-Regular.ttf *
        skins/DSx/DSx_Font_Files/Helvetica.ttc *
        skins/DSx/DSx_Font_Files/Montserrat-Regular.ttf *
        skins/DSx/DSx_Font_Files/notosansuiregular.ttf *
        skins/DSx/DSx_Font_Files/Roboto-Regular.ttf *
        skins/DSx/DSx_Font_Files/Skia.ttf *
        skins/DSx/DSx_Home_Page/DSx_2021_home.page *
        skins/DSx/DSx_Plugins/DSx_admin.dsx *
        skins/DSx/DSx_Plugins/DSx_backup.dsx *
        skins/DSx/DSx_Plugins/DSx_cal.dsx *
        skins/DSx/DSx_Plugins/DSx_coffee.dsx *
        skins/DSx/DSx_Plugins/DSx_flow_check.off *
        skins/DSx/DSx_Plugins/DSx_plugin_UI.dsx *
        skins/DSx/DSx_Plugins/DSx_theme.dsx *
        skins/DSx/DSx_Plugins/DSx_workflow.dsx *
        skins/DSx/DSx_Plugins/EY_calculator.off *
        skins/DSx/DSx_Plugins/history_delete.off *
        skins/DSx/DSx_Plugins/history_zoom.dsx *
        skins/DSx/DSx_Plugins/Pizza_dough.off *
        skins/DSx/DSx_Plugins/step_to_history.off *
        skins/DSx/DSx_Plugins/wake_to_pinkcup.off *
        skins/DSx/DSx_User_Set/.keep *
        skins/DSx/skin.tcl *

        saver/1280x800/black_saver.jpg *
        saver/1280x800/emmyart1.jpg *
        saver/1280x800/Black\ Steel.jpg *
        saver/1280x800/Cozy-Home.jpg *
        saver/1280x800/Floral.jpg *
        saver/1280x800/Lomen.jpg *
        saver/1280x800/apartment.jpg *
        saver/1280x800/aztec.jpg *
        saver/1280x800/cafe_girls.jpg *
        saver/1280x800/cities.jpg *
        saver/1280x800/cups.jpg *
        saver/1280x800/dark_choices.jpg *
        saver/1280x800/green-cup.jpg *
        saver/1280x800/photomanipulation.jpg *
        saver/1280x800/graffiti_1.jpg *
        saver/1280x800/graffiti_2.jpg *
        saver/1280x800/graffiti_wall.jpg *
        saver/1280x800/jim_shaw.jpg *
        saver/1280x800/minimalism.jpg *
        saver/1280x800/splash_noir.jpg *
        saver/1280x800/splotch.jpg *
        saver/1280x800/steampunk_espresso.jpg *
        saver/1280x800/steampunk_latte.jpg *
        saver/1280x800/three_women.jpg *
        saver/1280x800/rainbow_dj.jpg *
        saver/2560x1600/black_saver.jpg *
        saver/2560x1600/emmyart1.jpg *
        saver/2560x1600/Black\ Steel.jpg *
        saver/2560x1600/Cozy-Home.jpg *
        saver/2560x1600/Floral.jpg *
        saver/2560x1600/Lomen.jpg *
        saver/2560x1600/apartment.jpg *
        saver/2560x1600/aztec.jpg *
        saver/2560x1600/cafe_girls.jpg *
        saver/2560x1600/cities.jpg *
        saver/2560x1600/cups.jpg *
        saver/2560x1600/dark_choices.jpg *
        saver/2560x1600/french_breakfast.jpg *
        saver/2560x1600/graffiti_1.jpg *
        saver/2560x1600/graffiti_2.jpg *
        saver/2560x1600/graffiti_wall.jpg *
        saver/2560x1600/jim_shaw.jpg *
        saver/2560x1600/minimalism.jpg *
        saver/2560x1600/green-cup.jpg *
        saver/2560x1600/photomanipulation.jpg *
        saver/2560x1600/splash_noir.jpg *
        saver/2560x1600/splotch.jpg *
        saver/2560x1600/steampunk_espresso.jpg *
        saver/2560x1600/steampunk_latte.jpg *
        saver/2560x1600/three_women.jpg *
        saver/2560x1600/rainbow_dj.jpg *

        profiles/I_got_your_back.tcl *
        profiles/Tea_portafilter__Blue_Willow_Tsuyuhikari_Sencha.tcl *
        profiles/Tea_portafilter__Blue_Willow_Black_Honey_Oolong.tcl *
        profiles/Tea_portafilter__Blue_Willow_lunar_winter.tcl *
        profiles/Tea_portafilter__Blue_Willow_black_phoenix_1.tcl *
        profiles/Tea_portafilter__Blue_Willow_black_phoenix_2.tcl *
        profiles/tea_in_a_basket.tcl *
        profiles/adaptive_allonge.tcl *
        profiles/easy_blooming_active_pressure_decline.tcl *
        profiles/TurboBloom.tcl *
        profiles/TurboTurbo.tcl *
        profiles/Filter_20.tcl *
        profiles/Filter_21.tcl *
        profiles/best_practice.tcl *
        profiles/flow_calibration.tcl *
        profiles/7g\ basket.tcl *
        profiles/cleaning_forward_flush.tcl *
        profiles/Cleaning_forward_flush_x5.tcl *
        profiles/adaptive_espresso.tcl *
        profiles/Best\ overall\ pressure\ profile.tcl *
        profiles/weber_spring_clean.tcl *
        profiles/Gentle\ and\ sweet.tcl *
        profiles/tea_portafilter.tcl *
        profiles/tea_portafilter_oolong_dark.tcl *
        profiles/tea_portafilter_oolong.tcl *
        profiles/tea_portafilter_no_pressure.tcl *
        profiles/tea_portafilter_chinese_green.tcl *
        profiles/tea_portafilter_japanese_green.tcl *
        profiles/tea_portafilter_white.tcl *
        profiles/tea_portafilter_tisane.tcl *
        profiles/test_leak.tcl *
        profiles/test_for_a_small_low_pressure_leak.tcl *
        profiles/test_temperature.tcl *
        profiles/test_pressure_calibration.tcl *
        profiles/test_temperature_calibration.tcl *
        profiles/test_pressure_release.tcl *
        profiles/Cremina.tcl *
        profiles/manual_flow.tcl *
        profiles/manual_pressure.tcl *
        profiles/Advanced\ spring\ lever.tcl *
        profiles/Blooming\ espresso.tcl *
        profiles/cold_brew.tcl *
        profiles/kalita_20.tcl *
        profiles/Blooming\ allonge.tcl *
        profiles/Classic\ Italian\ espresso.tcl *
        profiles/Flow\ profile\ for\ milky\ drinks.tcl *
        profiles/Flow\ profile\ for\ straight\ espresso.tcl *
        profiles/Gentle\ flat\ 2.5\ ml\ per\ second.tcl *
        profiles/Gentle\ preinfusion\ flow\ profile.tcl *
        profiles/Pour\ over.tcl *
        profiles/Gentler\ but\ still\ traditional\ 8.4\ bar.tcl *
        profiles/Hybrid\ pour\ over\ espresso.tcl *
        profiles/Low\ pressure\ lever\ machine\ at\ 6\ bar.tcl *
        profiles/Preinfuse\ then\ 45ml\ of\ water.tcl *
        profiles/Traditional\ lever\ machine.tcl *
        profiles/Trendy\ 6\ bar\ low\ pressure\ shot.tcl *
        profiles/Two\ spring\ lever\ machine\ to\ 9\ bar.tcl *
        profiles/Innovative\ long\ preinfusion.tcl *
        profiles/default.tcl *
        profiles/rao_allonge.tcl *
        profiles/e61\ classic\ at\ 9\ bar.tcl *
        profiles/e61\ rocketing\ up\ to\ 10\ bar.tcl *
        profiles/e61\ with\ fast\ preinfusion\ to\ 9\ bar.tcl *
        profiles/Italian\ Australian\ espresso.tcl *
        profiles/v60-15g.tcl *
        profiles/v60-20g.tcl *
        profiles/v60-22g.tcl *

        profiles/Damian's\ LM\ Leva.tcl *
        profiles/Damian's\ LRv2.tcl *
        profiles/Damian's\ LRv3.tcl *

        plugins/visualizer_upload/plugin.tcl *
        plugins/D_Flow_Espresso_Profile/plugin.tcl *
        plugins/log_upload/plugin.tcl *
        plugins/old_lcd_disable/plugin.tcl *
        plugins/DPx_Screen_Saver/plugin.tcl *
        plugins/DPx_Steam_Stop/plugin.tcl *
        plugins/keyboard_control/plugin.tcl *
        plugins/keyboard_control/settings.tdb *
        plugins/log_debug/plugin.tcl *

        allcerts.pem *
    }

    # Have skins deal with their own filelist if they want to
    set skin_folders [lsort -dictionary [glob -nocomplain -tails -type d -directory "$srcdir/skins" * ]]
    puts "Checking for skin filelists in $skin_folders"

    foreach s $skin_folders {
        set fbasename [file rootname [file tail $s]]
        # We skip the old metric folder when creating the manifest now. This might now work on windows... :(
        if {$fbasename == "metric"} {
            continue
        }

        if {[file exists "$srcdir/skins/$fbasename/filelist.txt"] == 1} {
            set log_files {}
            puts "Found filelist.txt in $srcdir/skins/$fbasename/filelist.txt"
            set a [open "$srcdir/skins/$fbasename/filelist.txt"]
            set lines [split [read $a] "\n"]
            close $a;
            foreach line $lines {
                if {$line eq {}} {
                    continue
                }
                lappend files "skins/$fbasename/$line" *
                lappend log_files "skins/$fbasename/$line"
            }
            puts "Files added from filelists: $log_files"
        }
    }

    set plugin_folders [lsort -dictionary [glob -nocomplain -tails -type d -directory "$srcdir/plugins" * ]]
    puts "Checking for plugin filelists in $plugin_folders"

    foreach s $plugin_folders {
        set fbasename [file rootname [file tail $s]]
        if {[file exists "$srcdir/plugins/$fbasename/filelist.txt"] == 1} {
            set log_files {}
            puts "Found filelist.txt in $srcdir/plugins/$fbasename/filelist.txt"
            set a [open "$srcdir/plugins/$fbasename/filelist.txt"]
            set lines [split [read $a] "\n"]
            close $a;
            foreach line $lines {
                if {$line eq {}} {
                    continue
                }
                lappend files "plugins/$fbasename/$line" *
                lappend log_files "plugins/$fbasename/$line"
            }
            puts "Files added from filelists: $log_files"
        }
    }

    set old_timestamp 0
    # load the local manifest into memory
    foreach {filename filesize filemtime filesha} [string trim [read_file "$srcdir/complete_manifest.txt"]] {
        #puts "$filename $filecrc"
        set lmanifest_mtime($filename) $filemtime
        set lmanifest_sha($filename) $filesha
        if {$filemtime > $old_timestamp} {
            set old_timestamp $filemtime
        }
    }

    array set original_manifest_sha [array get lmanifest_sha]

    set timestamp [clock seconds]
    set dircount  0
    foreach destdir $destdirs {
        if {[file exists $destdir] != 1} {
            file mkdir $destdir
        }


        set manifest ""
        set files_copied 0

        set prev_existing_file {}

        set filecnt 0
        foreach {file scope} $files {
            incr filecnt
            if {$filecnt > 10} {
                #break
            }

            set source "$srcdir/$file"
            set dest "$destdir/$file"

            if {[file exists $source] != 1} {
                puts "File '$source' ($file) does not exist, previous file was: '$prev_existing_file'"
                continue
            }

            set prev_existing_file $file

            set mtime [file mtime $source]
            set mtime_saved [ifexists lmanifest_mtime($file)]

            if {([info exists lmanifest_sha($file)] == 1) && ($mtime ==  $mtime_saved)} {
                set sha256 $lmanifest_sha($file)
            } else {
                puts -nonewline "Calculating SHA256 for $source ... "
                set sha256 [calc_sha $source]

                #puts $sha256
                if {[ifexists lmanifest_sha($file)] == $sha256} {
                    puts "Timestamp changed, file identical, skipping"
                } else {
                    set lmanifest_sha($file) $sha256
                    set lmanifest_mtime($file) $mtime
                    puts $sha256
                }
            }

            lappend complete_manifest "\"$file\" [file size $source] [file mtime $source] $sha256"

            if {$scope != $dircount && $scope != "*"} {
                # puts skip copying files that are not part of this scope
                continue
            }
            if {[file exists [file dirname $dest]] != 1} {
                file mkdir [file dirname $dest]
            }

            if {[file exists $source] != 1} {
                puts "File '$source' does not exist'"
                continue
            }

            append manifest "\"$file\" [file size $source] $mtime $sha256\n"

            if {[file exists $dest] == 1} {
                if {[file mtime $source] == [file mtime $dest]} {
                    # files are identical, do not copy
                    continue
                }
            }

            puts "Copying $file -> $destdir/"
            file copy -force $source $dest
            #puts "- done copying $file -> $destdir/"
        }

        foreach k [array names lmanifest_sha] {
            if {[ifexists original_manifest_sha($k)] != [set lmanifest_sha($k)]} {
                set files_copied 1
            }
        }
        
        if {$files_copied == 0} {
            puts "Not generating a new timestamp as no files are new"
            set timestamp [expr $old_timestamp + 1]
        }

        #puts "Writing timestamp to '$destdir/timestamp.txt'"
        write_file "$destdir/timestamp.txt" $timestamp

        #puts "Writing manifest txt to '$destdir/manifest.txt'"
        write_file "$destdir/manifest.txt" $manifest

        # it might be that .txt files are modified, so try another extension name
        #puts "Writing manifest tdb to '$destdir/manifest.tdb'"
        write_file "$destdir/manifest.tdb" $manifest

        #puts "Writing manifest gz to '$destdir/manifest.gz'"
        write_binary_file "$destdir/manifest.gz" [zlib gzip $manifest]

        incr dircount
    }

    write_file "$srcdir/complete_manifest.txt" [join [lsort -unique $complete_manifest] \n]
    return $files_copied
}

proc write_binary_file {filename data} {
    set fn [fast_write_open $filename w]
    fconfigure $fn -translation binary
    puts $fn $data
    close $fn
    return 1
}



proc calc_sha_obsolete {source} {

    #return [::crc::crc32 -filename $source]
    return [::sha2::sha256 -hex -filename $source]
}


