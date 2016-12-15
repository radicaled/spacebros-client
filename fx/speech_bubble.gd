
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

# TODO:
# - Deal with too long text
#	Scroll?
#	Delay fade out until scrolled?
#	Chop into several messages?
# - Fix theme padding. Or figure out how to pad controls. Look it's one of those.
#	The editor view isn't synchronized with the runtime mechanics.
#	So I have no idea what rules its using since the editor view is a lie.
#	LOOK UPON THE ABOVE COMMENT WITH SHAME GODOT DEVELOPERS.
func display_text(text):
	get_node("PanelContainer/Label").set_text(text)
	get_node("Timer").start()

# Callbacks

# Fade the text out, I guess?
func _on_Timer_timeout():
	get_node("AnimationPlayer").play("text fade")
