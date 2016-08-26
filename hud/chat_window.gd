
extends Panel

# member variables here, example:
# var a=2
# var b="textvar"

signal text_submitted(text)

const TEXT_SUBMITTED = "text_submitted"

onready var text_input = get_node("Text Input")
onready var chat_log   = get_node("Chat Log")
func _ready():
	chat_log.set_scroll_follow(true)


func append_chat_text(text):
	chat_log.add_text("\r\n")
	chat_log.add_text(text)

func focus_chat_input():
	var node = get_node("Text Input")
	node.grab_focus()

func has_focus():
	return .has_focus() || get_node("Text Input").has_focus()

func _on_Text_Input_text_entered( text ):
	text_input.accept_event()
	if text.length() > 0:
		text_input.set_text("")
		text_input.release_focus()
		emit_signal(TEXT_SUBMITTED, text)
	else:
		text_input.release_focus()


func _on_Text_Input_input_event( ev ):
	if text_input.has_focus():
		if ev.is_action_pressed("ui_cancel"):
			text_input.release_focus()
			text_input.accept_event()
