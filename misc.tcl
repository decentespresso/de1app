package provide de1_misc 1.0

proc make_de1_dir {} {

    set not_these  {
        splash/1280x800/1960.jpg *
        splash/1280x800/8bit.jpg *
        splash/1280x800/aliens.jpg *
        splash/1280x800/chalkboard.jpg *
        splash/1280x800/circus.jpg *
        splash/1280x800/dark_choices.jpg *
        splash/1280x800/dark_comic.jpg *
        splash/1280x800/fashion_girls.jpg *
        splash/1280x800/grey_room.jpg *
        splash/1280x800/jackpot.jpg *
        splash/1280x800/jimshaw.jpg *
        splash/1280x800/leonardo.jpg *
        splash/1280x800/manga_girls.jpg *
        splash/1280x800/manga_outfits.jpg *
        splash/1280x800/modern.jpg *
        splash/1280x800/warhol.jpg *
        splash/1280x800/watercolor.jpg *
        splash/1280x800/wired_superheroes.jpg *

        splash/2560x1600/1960.jpg *
        splash/2560x1600/8bit.jpg *
        splash/2560x1600/aliens.jpg *
        splash/2560x1600/chalkboard.jpg *
        splash/2560x1600/circus.jpg *
        splash/2560x1600/dark_choices.jpg *
        splash/2560x1600/dark_comic.jpg *
        splash/2560x1600/fashion_girls.jpg *
        splash/2560x1600/grey_room.jpg *
        splash/2560x1600/jackpot.jpg *
        splash/2560x1600/jimshaw.jpg *
        splash/2560x1600/leonardo.jpg *
        splash/2560x1600/manga_girls.jpg *
        splash/2560x1600/manga_outfits.jpg *
        splash/2560x1600/modern.jpg *
        splash/2560x1600/warhol.jpg *
        splash/2560x1600/watercolor.jpg *
        splash/2560x1600/wired_superheroes.jpg *



    }

        #fonts/NotoSansCJKjp-ThinSansCJKjp-DemiLight.otf *
        #fonts/NotoSansCJKjp-Thin.otf *
        #fonts/NotoSansCJKjp-Medium.otf *

    set files {
        binary.tcl *
        bluetooth.tcl *
        translation.tcl *
        de1plus.tcl 1
        de1.tcl *
        gui.tcl *
        machine.tcl *
        utils.tcl *
        main.tcl *
        vars.tcl *
        updater.tcl *
        misc.tcl *
        pkgIndex.tcl *
        de1_icon_v2.png *
        de1plus_icon_v2.png 1
        cloud_download_icon.png *
        create_de1_icon.tcl 1
        create_de1plus_icon.tcl 1
        create_de1_update_icon.tcl 1
        appupdate.tcl *
        autopair_with_de1.tcl *
        autopair_with_de1plus.tcl *
        history_export.tcl *

        history/info.txt *
        history/export/readme.txt *

        fw/bootfwupdate.dat *
        wallpaper/spy_1280x800.jpg *
        wallpaper/spy_2560x1600.jpg *
        sounds/KeypressStandard_120.ogg *
        sounds/KeypressDelete_120.ogg *

        fonts/NotoSansCJKjp-Bold.otf *
        fonts/NotoSansCJKjp-Regular.otf *
        fonts/notosansuibold.ttf *
        fonts/notosansuiregular.ttf *
        fonts/sarabun.ttf *
        fonts/sarabunbold.ttf *

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
        skins/default/1280x800/espresso_on.png *
        skins/default/1280x800/steam_on.png *
        skins/default/1280x800/tea_on.png *
        skins/default/1280x800/sleep.jpg *
        skins/default/1280x800/filling_tank.jpg *
        skins/default/1280x800/fill_tank.jpg *
        skins/default/1280x800/cleaning.jpg *
        skins/default/1280x800/settings_message.png  *
        skins/default/1280x800/settings_3_choices.png  *
        skins/default/1280x800/descaling.jpg *
        skins/default/1280x800/settings_1.png *
        skins/default/1280x800/settings_2.png 1
        skins/default/1280x800/settings_2a.png 1
        skins/default/1280x800/settings_2a2.png 1
        skins/default/1280x800/settings_2b.png 1
        skins/default/1280x800/settings_2b2.png 1
        skins/default/1280x800/settings_2c.png 1
        skins/default/1280x800/settings_2c2.png 1
        skins/default/1280x800/settings_3.png *
        skins/default/1280x800/settings_4.png *
        skins/default/1280x800/icon.jpg *
        skins/default/1280x800/travel_do.jpg *
        skins/default/1280x800/travel_prepare.jpg *
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
        skins/default/2560x1600/descaling.jpg *
        skins/default/2560x1600/settings_1.png *
        skins/default/2560x1600/settings_2.png 1
        skins/default/2560x1600/settings_2a.png 1
        skins/default/2560x1600/settings_2a2.png 1
        skins/default/2560x1600/settings_2b.png 1
        skins/default/2560x1600/settings_2b2.png 1
        skins/default/2560x1600/settings_2c.png 1
        skins/default/2560x1600/settings_2c2.png 1
        skins/default/2560x1600/settings_3.png *
        skins/default/2560x1600/settings_4.png *
        skins/default/2560x1600/icon.jpg *
        skins/default/2560x1600/travel_do.jpg *
        skins/default/2560x1600/travel_prepare.jpg *
        
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

        skins/Insight/1280x800/icon.jpg 1
        skins/Insight/skin.tcl 1
        skins/Insight/scentone.tcl 1
        skins/Insight/1280x800/espresso_1.png 1
        skins/Insight/1280x800/espresso_1_zoomed.png 1
        skins/Insight/1280x800/espresso_2.png 1
        skins/Insight/1280x800/espresso_2_zoomed.png 1
        skins/Insight/1280x800/espresso_3.png 1
        skins/Insight/1280x800/espresso_3_zoomed.png 1
        skins/Insight/1280x800/steam_1.png 1
        skins/Insight/1280x800/steam_2.png 1
        skins/Insight/1280x800/steam_3.png 1
        skins/Insight/1280x800/water_1.png 1
        skins/Insight/1280x800/water_2.png 1
        skins/Insight/1280x800/water_3.png 1
        skins/Insight/1280x800/preheat_1.png 1
        skins/Insight/1280x800/preheat_2.png 1
        skins/Insight/1280x800/preheat_3.png 1
        skins/Insight/1280x800/preheat_4.png 1
        skins/Insight/1280x800/scentone_1.jpg 1
        skins/Insight/1280x800/scentone_tropical.jpg 1
        skins/Insight/1280x800/scentone_berry.jpg 1
        skins/Insight/1280x800/scentone_citrus.jpg 1
        skins/Insight/1280x800/scentone_stone.jpg 1
        skins/Insight/1280x800/scentone_cereal.jpg 1
        skins/Insight/1280x800/scentone_chocolate.jpg 1
        skins/Insight/1280x800/scentone_flower.jpg 1
        skins/Insight/1280x800/scentone_spice.jpg 1
        skins/Insight/1280x800/scentone_vegetable.jpg 1
        skins/Insight/1280x800/scentone_savory.jpg 1
        skins/Insight/1280x800/describe_espresso0.jpg 1
        skins/Insight/1280x800/describe_espresso.jpg 1
        skins/Insight/1280x800/describe_espresso2.jpg 1
        skins/Insight/2560x1600/icon.jpg 1
        skins/Insight/2560x1600/espresso_1.png 1
        skins/Insight/2560x1600/espresso_1_zoomed.png 1
        skins/Insight/2560x1600/espresso_2.png 1
        skins/Insight/2560x1600/espresso_2_zoomed.png 1
        skins/Insight/2560x1600/espresso_3.png 1
        skins/Insight/2560x1600/espresso_3_zoomed.png 1
        skins/Insight/2560x1600/steam_1.png 1
        skins/Insight/2560x1600/steam_2.png 1
        skins/Insight/2560x1600/steam_3.png 1
        skins/Insight/2560x1600/water_1.png 1
        skins/Insight/2560x1600/water_2.png 1
        skins/Insight/2560x1600/water_3.png 1
        skins/Insight/2560x1600/preheat_1.png 1
        skins/Insight/2560x1600/preheat_2.png 1
        skins/Insight/2560x1600/preheat_3.png 1
        skins/Insight/2560x1600/preheat_4.png 1
        skins/Insight/2560x1600/scentone_1.jpg 1
        skins/Insight/2560x1600/scentone_tropical.jpg 1
        skins/Insight/2560x1600/scentone_berry.jpg 1
        skins/Insight/2560x1600/scentone_citrus.jpg 1
        skins/Insight/2560x1600/scentone_stone.jpg 1
        skins/Insight/2560x1600/scentone_cereal.jpg 1
        skins/Insight/2560x1600/scentone_chocolate.jpg 1
        skins/Insight/2560x1600/scentone_flower.jpg 1
        skins/Insight/2560x1600/scentone_spice.jpg 1
        skins/Insight/2560x1600/scentone_vegetable.jpg 1
        skins/Insight/2560x1600/scentone_savory.jpg 1
        skins/Insight/2560x1600/describe_espresso0.jpg 1
        skins/Insight/2560x1600/describe_espresso.jpg 1
        skins/Insight/2560x1600/describe_espresso2.jpg 1

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

        profiles/Gentle\ and\ sweet.tcl *
        profiles/Blooming\ espresso.tcl *
        profiles/Classic\ Italian\ espresso.tcl *
        profiles/Flow\ profile\ for\ milky\ drinks.tcl 1
        profiles/Flow\ profile\ for\ straight\ espresso.tcl 1
        profiles/Gentle\ flat\ 2.5\ ml\ per\ second.tcl 1
        profiles/Gentle\ preinfusion\ flow\ profile.tcl 1
        profiles/Pour\ over.tcl 1
        profiles/Gentler\ but\ still\ traditional\ 8.4\ bar.tcl *
        profiles/Hybrid\ pour\ over\ espresso.tcl 1
        profiles/Low\ pressure\ lever\ machine\ at\ 6\ bar.tcl *
        profiles/Preinfuse\ then\ 45ml\ of\ water.tcl 1
        profiles/Best\ overall\ pressure\ profile.tcl *
        profiles/Traditional\ lever\ machine.tcl *
        profiles/Trendy\ 6\ bar\ low\ pressure\ shot.tcl *
        profiles/Two\ spring\ lever\ machine\ to\ 9\ bar.tcl *
        profiles/Innovative\ long\ preinfusion.tcl 1
        profiles/default.tcl *
        profiles/e61\ classic\ at\ 9\ bar.tcl *
        profiles/e61\ rocketing\ up\ to\ 10\ bar.tcl *
        profiles/e61\ with\ fast\ preinfusion\ to\ 9\ bar.tcl *      
        profiles/Italian\ Australian\ espresso.tcl *
        profiles/EspressoForge_Light.tcl *
        profiles/EspressoForge_Dark.tcl *
    }
#        profiles/Traditional\ lever\ machine\ at\ 9\ bar.tcl *
#        profiles/Powerful\ 10\ bar\ shot.tcl *

    set srcdir "/d/admin/code/de1beta"
    set destdirs [list "/d/download/sync/de1" "/d/download/sync/de1plus" "/d/download/sync/de1plusbig"]

    # load the local manifest into memory 
    foreach {filename filesize filemtime filesha} [string trim [read_file "[homedir]/complete_manifest.txt"]] {
        #puts "$filename $filecrc"
        set lmanifest_mtime($filename) $filemtime
        set lmanifest_sha($filename) $filesha
    }


    set timestamp [clock seconds]
    set dircount  0
    foreach destdir $destdirs {
        if {[file exists $destdir] != 1} {
            file mkdir $destdir
        }


        set manifest ""
        set files_copied 0
        
        set filecnt 0
        foreach {file scope} $files {
            incr filecnt
            if {$filecnt > 10} {
                #break
            }

            set source "$srcdir/$file"
            set dest "$destdir/$file"

            set mtime [file mtime $source]
            set mtime_saved [ifexists lmanifest_mtime($file)]

            if {([info exists lmanifest_sha($file)] == 1) && ($mtime ==  $mtime_saved)} {
                set sha256 $lmanifest_sha($file)
            } else {
                puts -nonewline "Calculating SHA256 for $source : "
                set sha256 [calc_sha $source]
                puts $sha256
                set lmanifest_sha($file) $sha256
                set lmanifest_mtime($file) $mtime
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

            puts "$file -> $destdir/"
            file copy -force $source $dest
            set files_copied 1
        }

        write_file "$destdir/timestamp.txt" $timestamp
        write_file "$destdir/manifest.txt" $manifest 
        incr dircount
    }

    write_file "$srcdir/complete_manifest.txt" [join [lsort -unique $complete_manifest] \n]
}

proc calc_sha {source} {

    #return [::crc::crc32 -filename $source]
    return [::sha2::sha256 -hex -filename $source]
}

