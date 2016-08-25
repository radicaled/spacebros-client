
extends Node2D

signal text_submitted(text)

const TEXT_SUBMITTED = "text_submitted"

func _ready():
	var label = get_node("Panel/RichTextLabel")
	label.set_scroll_follow(true)

func append_chat_text(text):
	var label = get_node("Panel/RichTextLabel")
	label.add_text("\r\n")
	label.add_text(text)

func _on_Text_Input_input_event( ev ):
	var node = get_node("Panel/Text Input")
	var text = node.get_text()
	if ev.is_action_pressed("text_submit") && text.length() > 0:
		node.set_text("")
		emit_signal(TEXT_SUBMITTED, text)
