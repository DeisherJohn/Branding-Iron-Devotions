extends Node

#This file is used for storing/retrieving use settings and settings up other portions of the app.
#	Copyright (C) 2020  John Deisher
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#	Contact me via email at john.deisher2013@gmail.com

const ROOT_DIR = "res://"
const CONFIG_FILE_PATH = "config.cfg"

var settings = {
	"user_options":{
		"save_posts":false,
		"dark_mode":false
	},
	"paths":{
		"wp_json_data":ROOT_DIR + "wp_data.json"
	}
}

var config = ConfigFile.new()

func _ready():
	var file = File.new()
	var does_config_exist = file.file_exists(ROOT_DIR + CONFIG_FILE_PATH)
	
	if not does_config_exist:
		print("Saving settings to: %s%s"%[ROOT_DIR,CONFIG_FILE_PATH])
		save_settings()
	else:
		print("Loading settings from: %s%s"%[ROOT_DIR,CONFIG_FILE_PATH])
		load_settings()

func load_settings():
	var error = config.load(ROOT_DIR + CONFIG_FILE_PATH)
	
	if error != OK:
		print("Config file did not open, ERROR: %s" % error)
		return
	
	#makes sure that all settings above are in the settings file.
	for section in settings:
		for key in settings[section]:
			if not config.has_section_key(section, key):
				#config is missing a settings section
				config.set_value(section, key, settings[section][key])
			else:
				#gets the key stored in the file
				settings[section][key] = config.get_value(section, key)
	
	#this catches anything that was saved into the file but is not in the top json dict
	for section in config.get_sections():
		for key in config.get_section_keys(section):
			settings[section][key] = config.get_value(section, key)
			
	config.save(ROOT_DIR + CONFIG_FILE_PATH)

func save_settings():
	for section in settings:
		for key in settings[section]:
			print("Section: %s, Key: %s" %[section, key])
			config.set_value(section, key, settings[section][key])
	
	config.save(ROOT_DIR + CONFIG_FILE_PATH)

func get_save_option():
	#returns the "save_post" option
	return settings["user_options"]["save_posts"]
func set_save_option(value : bool = false):
	#sets the save option into the config file
	if value == null:
		return
		
	settings["user_options"]["save_posts"] = value
	save_settings()

func get_dark_option():
	#returns the "save_post" option
	return settings["user_options"]["dark_mode"]
func set_dark_option(value : bool = false):
	if value == null:
		return
	
	settings["user_options"]["dark_mode"] = value
	save_settings()
	
func get_wp_path():
	#returns the path to the authors file
	return settings["paths"]["wp_json_data"]