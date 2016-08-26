
extends GridContainer

# member variables here, example:
# var a=2
# var b="textvar"

const LOOK_AT = "look_at"
const USE = "use"
const PICK_UP = "pick_up"
const GRAB = "grab"


var action_mode = LOOK_AT

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

# Members

func get_action_mode():
	return action_mode


# Callbacks

func _on_Look_At_pressed():
	action_mode = LOOK_AT


func _on_Use_pressed():
	action_mode = USE


func _on_Pick_Up_pressed():
	action_mode = PICK_UP


func _on_Grab_pressed():
	action_mode = GRAB
