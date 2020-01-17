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

const FIRST_POST_ID = 47

enum REQUEST_TYPE {NONE, AUTHOR, POSTS, CONTENT}

var WP_LOCAL_DATA = ConfigManager.get_wp_path()

var wp_fields = ["author", "id", "title", "date"]

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
	
	if not file.file_exists(WP_LOCAL_DATA):
		#create the file
		print("Saving settings to: %s"%WP_LOCAL_DATA)
		save_json_dict()
	else:
		#load the file
		print("Loading settings from: %s"%WP_LOCAL_DATA)
		load_json_dict()

func field_joiner(fields : Array = []):
	
	if fields.size() == 0:
		return ""
	
	return PoolStringArray(fields).join(",")

func char_replacer(data_string):
	data_string = data_string.replace("&nbsp;", " ")
	data_string = data_string.replace("&#8217;", "'")
	data_string = data_string.replace("&#8220;", "\"")
	data_string = data_string.replace("&#8221;", "\"")
	data_string = data_string.replace("&#8230;", "...")
	data_string = data_string.replace("&#8211;", "-")
	data_string = data_string.replace("\n", "")
	
	return data_string
	
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

func get_author_name(wp_id : int):
	#Function returns null if there is no author matching the id
	if wp_id == null:
		return null

	if wp_json_lib["authors"].has(str(wp_id)):
		return wp_json_lib["authors"][str(wp_id)]
	else:
		#Reqest the author from WP and see if it exist.
		return null
		
func set_author_name(wp_id : int, wp_name : String):
	wp_json_lib["authors"][str(wp_id)] = wp_name
	
	save_json_dict()
	pass

func get_post_header(post_id : int):
	if not wp_json_lib["posts"].has(str(post_id)):
		return null

	return wp_json_lib["posts"][str(post_id)]

func save_post_header(post_id : int, author : int, title : String, date : String, saved : bool = false, read : bool = false):
	
	title = char_replacer(title)
	
	wp_json_lib["posts"][str(post_id)] = {
		"author":author,
		"title":title,
		"date":date,
		"saved":saved,
		"read":read
	}
	
	ConfigManager.set_most_recent(date)
	save_json_dict()
	pass

func get_post_saved(post_id : int):
	if not wp_json_lib["posts"].has(str(post_id)):
		return false
	
	return wp_json_lib["posts"][str(post_id)]["saved"]

func set_post_saved(post_id : int, value : bool = false):
	if not wp_json_lib["posts"].has(str(post_id)):
		print("Post does not have entry: %s" % str(post_id))
		return false
	
	wp_json_lib["posts"][str(post_id)]["saved"] = value
	save_json_dict()

func get_post_read(post_id : int):
	if not wp_json_lib["posts"].has(str(post_id)):
		return false
	
	return wp_json_lib["posts"][str(post_id)]["read"]

func set_post_read(post_id : int, value : bool = false):
	if not wp_json_lib["posts"].has(str(post_id)):
		print("Post does not have entry: %s" % str(post_id))
		return false
	
	wp_json_lib["posts"][str(post_id)]["read"] = value
	save_json_dict()

func load_post_content_file(post_id):
	var file = File.new()
	var file_path = ConfigManager.ROOT_DIR + "/posts/post" + str(post_id) + ".txt"
	
	if not file.file_exists(file_path):
		print("File does not exist: %s%s"%file_path)
		return false

	var error = file.open(file_path, File.READ)
	
	if error != OK:
		print("Post file could not be opened: %s, Error: %s" % [file_path,error])
		return false

	var line = ""

	while not file.eof_reached():
		line += file.get_line()

	file.close()
	return line

func save_post_content_file(post_id : int, content : String):
	if post_id == null:
		return false
	var reduced_string = content.replace("\n", "")
	var file = File.new()
	var file_path = ConfigManager.ROOT_DIR + "/posts/post" + str(post_id) + ".txt"
	
	var error = file.open(file_path, File.WRITE)
	
	if error != OK:
		print("Could not open file for saving post: %s, path: " % [str(post_id),file_path])
		return false
	
	file.store_line(reduced_string)
	
	file.close()
	set_post_saved(post_id, true)
	return true

func get_most_recent_post_request_string():
	return ConfigManager.get_post_path() + "?orderby=date&order=desc&per_page=3&_fields=" + field_joiner(wp_fields)

func get_post_request_string(newest_post : String = "", number_of_posts : int = 10):
	var request_parms = "?orderby=date&order=asc"
	
	if newest_post != "":
		#There are no post saved, request all post to todays date
		#"2007-04-05T14:30" ISO8601 Datetime format
		request_parms += "&after=" + newest_post
	
	request_parms += "&_fields=" + field_joiner(wp_fields)
	request_parms += "&per_page=" + str(number_of_posts)
	
	return  ConfigManager.get_post_path() + request_parms

func get_author_request_string(author_id : int = -1):
	var request_string = ConfigManager.get_user_path() + "/"
	
	if author_id != -1:
		request_string += str(author_id)
	
	request_string += "?_fields=id,name"
	
	return request_string

func get_post_content_request_string(post_id : int):
	var fields = ["id","content"]
	
	if post_id == null: return ""
		
	return ConfigManager.get_post_path() + "?include=" + str(post_id) + "&_fields=" + field_joiner(fields)
	pass




















