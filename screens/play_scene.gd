
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	var hub = get_node("/root/global").network_hub
	hub.connect(hub.CREATE_ENTITY, self, '_on_create_entity')
	


func _on_create_entity(msg):
	pass
