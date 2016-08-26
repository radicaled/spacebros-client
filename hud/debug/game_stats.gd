
extends VBoxContainer

# member variables here, example:
# var a=2
# var b="textvar"

onready var global = get_node("/root/global")
onready var network_hub = global.network_hub

func _ready():
	set_process(true)

func _process(delta):
	if network_hub.get_connected():
		get_node("Connection Status").set_text("CONNECTED")
	else:
		get_node("Connection Status").set_text("DISCONNECTED")
	
	get_node("FPS").set_text("FPS: " + str(OS.get_frames_per_second()))


