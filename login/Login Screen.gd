extends Node2D

func _ready():
	get_node("Panel/LineEdit").grab_focus()
	set_process_input(true)
	
func _input(ev):
	if ev.is_action_pressed("text_submit"):
		login(get_node("Panel/LineEdit").get_text())

func login(username):
	var player_data = {
		"name": username
	}
	var global = get_node("/root/global")
	global.connectToServer(player_data)

func _on_Button_login(text):
	login(text)
