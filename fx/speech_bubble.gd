
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func display_text(text):
	get_node("Label").set_text(text)
	get_node("Timer").start()

# Callbacks

# Fade the text out, I guess?
func _on_Timer_timeout():
	get_node("AnimationPlayer").play("text fade")
