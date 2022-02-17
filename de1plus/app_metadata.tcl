
proc init_app_metadata {} {
	# Define the properties to be used in the app data dictionary
	metadata dictionary add domain [list validate_category {shot profile}]
	metadata dictionary add category validate_nonempty_string
	metadata dictionary add section validate_nonempty_string
	metadata dictionary add subsection validate_nonempty_string
	metadata dictionary add source [list validate_category {app user calc}]
	metadata dictionary add owner_type [list validate_category {base skin plugin}]
	metadata dictionary add owner
	metadata dictionary add name validate_nonempty_string
	metadata dictionary add name_plural validate_nonempty_string
	metadata dictionary add short_name validate_nonempty_string
	metadata dictionary add short_name_plural validate_nonempty_string
	metadata dictionary add description
	metadata dictionary add propagate validate_boolean
	metadata dictionary add data_type [list validate_category {text long_text category number boolean date}]
	metadata dictionary add required boolean
	metadata dictionary add length validate_length
	metadata dictionary add valid_values
	metadata dictionary add min [list string is double]
	metadata dictionary add max [list string is double]
	metadata dictionary add default
	metadata dictionary add smallincrement [list string is double]
	metadata dictionary add bigincrement [list string is double]
	metadata dictionary add n_decimals [list string is integer]
	metadata dictionary add measure_unit
	metadata dictionary add default_dui_widget [list validate_category {entry text listbox dcombobox dcheckbox drater dclicker}]	
	
	# Define the actual fields
	metadata add profile_title end {
		domain {profile shot}
		source app
		owner_type base
		name "Profile title"
		name_plural "Profile titles"
		short_name "Profile" 
		short_name_plural "Profiles"
		propagate 0
		data_type category
		required 1
		length 1
		default_dui_widget dcombobox
	}
	metadata add bean_brand end {
		domain shot
		category description
		section beans
		subsection beans_desc
		source user
		owner_type base
		name "Beans roaster"
		name_plural "Beans roaster"
		short_name "Roaster" 
		short_name_plural "Roasters"
		propagate 1
		data_type category
		required 0
		length 1
		default_dui_widget dcombobox
	}
	metadata add bean_type end {
		domain shot
		category description
		section beans
		subsection beans_desc
		source user
		owner_type base
		name "Beans type"
		name_plural "Beans type"
		short_name "Beans" 
		short_name_plural "Beans"
		propagate 1
		data_type category
		required 0
		length 1
		default_dui_widget dcombobox
	}
	metadata add roast_date end {
		domain shot
		category description
		section beans
		subsection beans_batch
		source user
		owner_type base
		name "Roast date"
		name_plural "Roast dates"
		short_name "Roasted" 
		short_name_plural "Roasted"
		propagate 1
		data_type text
		required 0
		length 1
		default_dui_widget entry
	}
	metadata add roast_level end {
		domain shot
		category description
		section beans
		subsection beans_batch
		source user
		owner_type base
		name "Roast level"
		name_plural "Roast levels"
		short_name "Roast lvl" 
		short_name_plural "Roast lvls"
		propagate 1
		data_type category
		required 0
		length 1
		default_dui_widget dcombobox
	}
	metadata add bean_notes end {
		domain shot
		category description
		section beans
		subsection beans_batch
		source user
		owner_type base
		name "Beans notes"
		name_plural "Beans notes"
		short_name "Notes" 
		short_name_plural "Notes"
		propagate 1
		data_type long_text
		required 0
		length 1
		default_dui_widget text
	}		
	metadata add grinder_model end {
		domain shot
		category description
		section equipment
		subsection grinder
		source user
		owner_type base
		name "Grinder model"
		name_plural "Grinder models"
		short_name "Grinder" 
		short_name_plural "Grinders"
		propagate 1
		data_type category
		required 0
		length 1
		default_dui_widget dcombobox
	}
	metadata add grinder_setting end {
		domain shot
		category description
		section equipment
		subsection grinder
		owner_type base
		source user
		name "Grinder setting"
		name_plural "Grinder settings"
		short_name "Grinder set" 
		short_name_plural "Grinder sets"
		propagate 1
		data_type category
		required 0
		length 1
		default_dui_widget dcombobox
	}
	metadata add grinder_dose_weight end {
		domain shot
		category description
		section extraction
		subsection ""
		source user
		owner_type base
		name "Dose weight"
		name_plural "Dose weights"
		short_name "Dose" 
		short_name_plural "Doses"
		propagate 1
		data_type number
		min 0.0
		max 30.0
		default 18.0
		smallincrement 0.1
		bigincrement 1.0
		n_decimals 1
		measure_unit g
		required 0
		length 1
		default_dui_widget dclicker
	}
	metadata add drink_weight end {
		domain shot
		category description
		section extraction
		subsection drink
		source user
		owner_type base
		name "Drink weight"
		name_plural "Drink weights"
		short_name "Yield" 
		short_name_plural "Yields"
		propagate 0
		data_type number
		min 0.0
		max 500.0
		default 36.0
		smallincrement 1.0
		bigincrement 10.0
		n_decimals 1
		measure_unit g
		required 0
		length 1
		default_dui_widget dclicker
	}
	metadata add drink_tds end {
		domain shot
		category description
		section extraction
		subsection drink
		source user
		owner_type base
		name "Total Dissolved Solids"
		name_plural "Total Dissolved Solids"
		short_name "TDS" 
		short_name_plural "TDS"
		propagate 0
		data_type number
		min 0.0
		max 25.0
		default 8.0
		smallincrement 0.01
		bigincrement 0.1
		n_decimals 2
		measure_unit %
		required 0
		length 1
		default_dui_widget dclicker
	}
	metadata add drink_ey end {
		domain shot
		category description
		section extraction
		subsection drink
		source user
		owner_type base
		name "Extraction Yield"
		name_plural "Extraction Yields"
		short_name "EY" 
		short_name_plural "EY"
		propagate 0
		data_type number
		min 0.0
		max 30.0
		default 18.0
		smallincrement 0.01
		bigincrement 0.1
		n_decimals 2
		measure_unit %
		required 0
		length 1
		default_dui_widget dclicker
	}
	metadata add espresso_notes end {
		domain shot
		category description
		section extraction
		subsection tasting
		source user
		owner_type base
		name "Espresso note"
		name_plural "Espresso notes"
		short_name "Note" 
		short_name_plural "Notes"
		propagate 0
		data_type long_text
		required 0
		length 1
		default_dui_widget text
	}	
	metadata add espresso_enjoyment end {
		domain shot
		category description
		section tasting
		subsection ""
		source user
		owner_type base
		name "Enjoyment (0-100)"
		name_plural "Enjoyment"
		short_name "Enjoyment" 
		short_name_plural "Enjoyment"
		propagate 0
		data_type number
		min 0
		max 100
		default 50
		smallincrement 1
		bigincrement 10
		n_decimals 0
		required 0
		length 1
		default_dui_widget drater
	}
	metadata add scentone end {
		domain shot
		category description
		section tasting
		subsection ""
		source user
		owner_type base
		name "Scentone flavours"
		name_plural "Scentone flavours"
		short_name "Scentone" 
		short_name_plural "Scentone"
		propagate 0
		data_type complex
		required 0
		length list
		default_dui_widget {}
	}	
	metadata add my_name end {
		domain shot
		category description
		section people
		subsection ""
		source user
		owner_type base
		name "Barista"
		name_plural "Baristas"
		short_name "Barista" 
		short_name_plural "Baristas"
		propagate 1
		data_type category
		required 0
		length 1
		default_dui_widget dcombobox
	}
	metadata add beverage_type end {
		domain profile
		category machine?
		section drink
		subsection ""
		source user
		owner_type base
		name "Beverage type"
		name_plural "Beverage types"
		short_name "Bev. type" 
		short_name_plural "Bev. types"
		propagate 0
		data_type category
		values {espresso tea_portafilter cleaning calibrate}
		required 1
		length 1
		default_dui_widget dcombobox
	}	
}