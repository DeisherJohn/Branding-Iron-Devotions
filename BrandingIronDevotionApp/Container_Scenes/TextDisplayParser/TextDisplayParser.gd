extends Control

#Displaying html markup as rich text
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

const TAG_LEADER = "<"
const TAG_TAIL = ">"

var label = null

func _ready():
	label = $RichTextLabel
	
func parse_line(content):
	
	if content == null or content == "":
		return
	
	content = PostManager.char_replacer(content)
	
	var tag = String()
	var tag_extra = String()
	
	var in_tag = false
	var in_link = false
	
	for c in content:
		if c == TAG_LEADER:
			#Possible html tag
			in_tag = true
			tag = ""
			tag_extra = ""
			continue
		elif c == TAG_TAIL:
			in_tag = false
			
			#search for possible tag match or push line into code
			
			match tag:
				"p":
					label.newline()
				"/p":
					label.newline()
				"strong":
					label.append_bbcode("[b]")
				"/strong":
					label.pop()
				"a href=\"":
					label.push_meta(tag_extra)
				"/a":
					label.pop()
				"pre class=\"wp-block-verse\"":
					label.newline()
					label.append_bbcode("[i]")
				"/pre":
					label.pop()
				"blockquote class=\"wp-block-quote\"":
					label.append_bbcode("[i]")
				"/blockquote":
					label.pop()
				"br":
					label.newline()
				_:
					label.add_text(TAG_LEADER + tag + TAG_TAIL)
			
			continue
				
		if in_link:
			#This ends a meta link so that it does not have the ending "
			if c == "\"":
				in_link = false
				continue
			tag_extra += c
			continue
		elif in_tag:
			tag += c
			
			if tag == "a href=\"": 
				in_link = true
			continue
		else:	
			label.add_text(c)


func _on_RichTextLabel_meta_clicked(meta):
	var error = OS.shell_open(meta)
	
	if error != OK:
		print("Error opening link: %s, ERROR: %s" % [meta, error])
	pass # Replace with function body.
