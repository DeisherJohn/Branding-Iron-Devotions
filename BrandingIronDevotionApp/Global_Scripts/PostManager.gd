extends Node

#This file is used for storing/retrieving of posts to be used by the app.
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


var WP_LOCAL_DATA = ConfigManager.get_wp_path()

var wp_json_lib = {
	"authors":{
		
	},
	"posts":{
		
	}
}
func _ready():
	
	if WP_LOCAL_DATA == null:
		return
		
	var file = File.new()
	
	var does_lib_exist = file.file_exists(WP_LOCAL_DATA)
	
	if not does_lib_exist:
		#create the file
		print("Saving settings to: %s"%WP_LOCAL_DATA)
		save_json_dict()
	else:
		#load the file
		print("Loading settings from: %s"%WP_LOCAL_DATA)
		load_json_dict()
	save_post_header(445, 2, "They Grow Up", "2019-12-31T01:00:00")
	
func save_json_dict():
	var file = File.new()
	var error = file.open(WP_LOCAL_DATA, File.WRITE)
	
	if error != OK:
		print("Could not open wp data to save: %s" % error)
		return
	
	file.store_line(to_json(wp_json_lib))
	file.close()
	pass
	
func load_json_dict():
	var file = File.new()
	
	file.open(WP_LOCAL_DATA, File.READ)
	
	wp_json_lib = parse_json(file.get_line())

	file.close()

func get_author_name(wp_id : int = -1):
	if wp_id == -1:
		return null
		
	var author_exist = wp_json_lib["authors"].has(str(wp_id))
	
	if author_exist:
		return wp_json_lib["authors"][str(wp_id)]
	else:
		return null
		
func set_author_name(wp_id : int, wp_name : String):
	wp_json_lib["authors"][str(wp_id)] = wp_name
	
	save_json_dict()
	pass

func get_post_header(post_id : int):
	if post_id == null:
		return null
		
	var author_exist = wp_json_lib["posts"].has(str(post_id))
	
	if author_exist:
		return wp_json_lib["posts"][str(post_id)]
	else:
		return null

func save_post_header(post_id : int, author : int, title : String, date : String, saved : bool = false):
	wp_json_lib["posts"][str(post_id)] = {
		"author":author,
		"title":title,
		"date":date,
		"saved":saved
	}
	save_json_dict()
	pass























