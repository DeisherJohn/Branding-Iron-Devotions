extends Control

var _read = false
var _favorite = false
var _title = ""
var _post_id = -1

signal post_button_pressed(post_id)


func fill_data(post_id : int, title : String, read : bool = false, favorite : bool = false):
	_post_id = post_id
	_title = title
	_read = read
	_favorite = favorite
	
	$HBoxContainer/Label.set_text(_title)
	$HBoxContainer/Bookmark.set_pressed(_read)
	$HBoxContainer/Favorite.set_pressed(_favorite)
	pass

func _on_Button_pressed():
	print("Main button")
	emit_signal("post_button_pressed", _post_id)
	pass # Replace with function body.


func _on_Favorite_toggled(button_pressed):
	_favorite = button_pressed
	PostManager.set_post_saved(_post_id, true)
	pass # Replace with function body.
