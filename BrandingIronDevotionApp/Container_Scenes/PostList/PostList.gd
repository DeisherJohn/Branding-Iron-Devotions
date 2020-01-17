extends Control

var PostBlock = preload("res://Container_Scenes/PostBlock/PostBlock.tscn")

signal post_selected(post_id)

var click = false
var drag = false

func _ready():
	populate_list()
	
func _input(event):
	if event is InputEventMouseButton:
		click = event.is_pressed()
	if event is InputEventMouseButton and click and drag:
		click = false
		drag = false
		get_tree().set_input_as_handled()
	elif event is InputEventMouseMotion and click:
		$ScrollContainer.set_v_scroll(($ScrollContainer.get_v_scroll() - event.get_relative().y) )
		drag = true
		
		
		
	
func populate_list():
#	for child in $ScrollContainer/VBoxContainer.get_children():
#		child.queue_free()
	
	var keys = PostManager.wp_json_lib["posts"].keys()
	
	var num_keys = Array()
	
	for key in keys:
		num_keys.append(int(key))
		
	num_keys.sort()
	
	for key in num_keys:
		if $ScrollContainer/VBoxContainer.get_node(str(key)) != null:
			continue
		
		var post_data = PostManager.get_post_header(int(key))
		var newBlock = PostBlock.instance()
		
		newBlock.fill_data(int(key), post_data["title"], post_data["read"], post_data["saved"])
		newBlock.name = str(key)
		newBlock.connect("post_button_pressed", self, "load_post")
		$ScrollContainer/VBoxContainer.add_child(newBlock)
		$ScrollContainer/VBoxContainer.move_child(newBlock, 0)

		if PostManager.get_author_name(int(post_data["author"])) == null:
			var req_string = PostManager.get_author_request_string(int(post_data["author"]))
			httpRequester.request(req_string, PostManager.REQUEST_TYPE.AUTHOR)
			pass
			
		
func load_post(post_id):
	emit_signal("post_selected", post_id)