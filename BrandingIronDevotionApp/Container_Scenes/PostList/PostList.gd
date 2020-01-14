extends Control

var PostBlock = preload("res://Container_Scenes/PostBlock/PostBlock.tscn")

signal post_selected(post_id)

func _ready():
	
	var keys = PostManager.wp_json_lib["posts"].keys()
	print(keys)
	
	for key in keys:
		var post_data = PostManager.get_post_header(int(key))
		print(post_data)
		var newBlock = PostBlock.instance()
		
		newBlock.fill_data(int(key), post_data["title"], post_data["read"], post_data["saved"])
		
		newBlock.connect("post_button_pressed", self, "load_post")
		$ScrollContainer/VBoxContainer.add_child(newBlock)
	pass


func load_post(post_id):
	emit_signal("post_selected", post_id)