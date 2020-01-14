extends Control

var requested_headers = false
var requested_content = false
var requested_user = false

func _ready():
	print("Start")
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Error in HTTP request -> result: %s \n\n response_code %s \n\n headers: %s" % [result, response_code, str(headers)])
		return
		
	if response_code != HTTPClient.RESPONSE_OK:
		print("Error in HTTP response -> result: %s \n\n response_code %s \n\n headers: %s" % [result, response_code, str(headers)])
		return
		
	var json = JSON.parse(body.get_string_from_utf8())
	var json_array = json.get_result()
	
	if requested_headers:
		for item in json_array:
			PostManager.save_post_header(item["id"],item["author"], item["title"]["rendered"], item["date"])
		requested_headers = false
	elif requested_content:
		PostManager.save_post_content_file(json_array[0]["id"], json_array[0]["content"]["rendered"])
		
		print("Loading File")
		var data = PostManager.load_post_content_file(439)
		$MarginContainer/TextDisplayParser.parse_line(data)
		
		if PostManager.get_author_name(2) == null:
			$HTTPRequest.request(ConfigManager.get_user_path() + "/" + str(2) + "?_fields=id,name")
			
			requested_user = true
			
		requested_content = false
	elif requested_user:
		PostManager.set_author_name(json_array["id"], json_array["name"])


func _on_Button_pressed():
	var recent_request_string = PostManager.get_most_recent_post_request_string()
	print("REQUEST STRING: %s" % recent_request_string)
	$HTTPRequest.request(recent_request_string)
	requested_headers = true
	pass # Replace with function body.


func _on_Button2_pressed():
	var content_req = PostManager.get_post_content_request_string(439)
	print("REQUEST STRING: %s" % content_req)
	$HTTPRequest.request(content_req)
	
	requested_content = true
	pass # Replace with function body.
