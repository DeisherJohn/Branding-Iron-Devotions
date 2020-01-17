extends Node

#This file is used for making httpRequests to WP sites
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

signal retrived_author(authors)
signal retrived_posts(posts)
signal retrived_content(content)
signal retrived_request(content)
signal no_new_data()

var requested_data = PostManager.REQUEST_TYPE.NONE

var httpRequester = null

func _ready():
	httpRequester = HTTPRequest.new()
	add_child(httpRequester)
	
	httpRequester.connect("request_completed", self, "_on_HTTPRequest_request_completed")


func request(request_string : String = "", type : int = PostManager.REQUEST_TYPE.NONE):
	if request_string == null or request_string == "":
		return
	
	if requested_data != PostManager.REQUEST_TYPE.NONE:
		return
	
	requested_data = type
	print("REQUEST_STRING: %s" % request_string)
	httpRequester.request(request_string)



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Error in HTTP request -> result: %s \n\n response_code %s \n\n headers: %s" % [result, response_code, str(headers)])
		return
		
	if response_code != HTTPClient.RESPONSE_OK:
		print("Error in HTTP response -> result: %s \n\n response_code %s \n\n headers: %s" % [result, response_code, str(headers)])
		return
		
	var json = JSON.parse(body.get_string_from_utf8())
	var json_array = json.get_result()
	print(json_array)
	if json_array.size() == 0:
		emit_signal("no_new_data")
	var this_request = requested_data
	requested_data = PostManager.REQUEST_TYPE.NONE
	
	match this_request:
		PostManager.REQUEST_TYPE.AUTHOR:
			for author in json_array:
				PostManager.set_author_name(json_array["id"], json_array["name"])
			emit_signal("retrived_author", json_array)
		PostManager.REQUEST_TYPE.POSTS:
			for item in json_array:
				PostManager.save_post_header(item["id"],item["author"], item["title"]["rendered"], item["date"])
			emit_signal("retrived_posts", json_array)
		PostManager.REQUEST_TYPE.CONTENT:
			if ConfigManager.get_save_option():
				#post needs to be saved
				for post in json_array:
					PostManager.save_post_content_file(json_array["id"], json_array["content"]["rendered"])
			
			emit_signal("retrived_content", json_array)
		_:
			emit_signal("retrived_request", json_array)
	pass
