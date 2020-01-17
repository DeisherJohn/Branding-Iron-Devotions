extends Control

var no_new_data = false

func _ready():
	httpRequester.connect("retrived_author", self, "got_author")
	httpRequester.connect("retrived_posts", self, "got_posts")
	httpRequester.connect("retrived_content", self, "got_content")
	httpRequester.connect("retrived_request", self, "got_request")
	httpRequester.connect("no_new_data", self, "no_newer_data")
	
	print("Start")
	get_all_new_posts()


func get_all_new_posts():
	
	while not no_new_data:
		var req_string = PostManager.get_post_request_string(ConfigManager.get_most_recent(),30)
	
		httpRequester.request(req_string, PostManager.REQUEST_TYPE.POSTS)
		print("YIELDING ON NEW DATA")
		yield(httpRequester, "retrived_posts")
		print("GOT NEW DATA")
		
	print("EXITED NEW DATA LOOP")
	pass
	
func got_author(json_data):
	print("GOT AUTHOR DATA")
	print(json_data)
	pass
	
func got_posts(json_data):
	print("GOT POST DATA")
	$VBoxContainer/PostList.populate_list()
	pass

func got_content(json_data):
	print("GOT CONTENT DATA")
	print(json_data)
	pass

func got_request(json_data):
	print("GOT REQUEST DATA")
	print(json_data)
	pass
	
func no_newer_data():
	no_new_data = true