extends Node

export(int) var door_closed_frame = 0
export(int) var door_opened_frame = 0
onready var entity_node = get_node("..")
onready var animation_player = get_node("../AnimationPlayer")
onready var sprite = get_node("../Sprite")
#export(NodePath) var entity_node_path setget set_entity_node_path
#export(NodePath) var animation_node_path
#export(NodePath) var sprite_node_path
#var entity_node = null

func _ready():
	entity_node.connect("state_update", self, '_on_state_update')
	_on_state_update(entity_node.get_entity_state())

#func set_entity_node_path(node_path):
#	if entity_node != null:
#		entity_node.disconnect("state_update")
#	entity_node = get_node(node_path)
#	entity_node.connect("state_update", '_on_state_update')

func _on_state_update(state):
	if state.door != null:
		var door_state = state.door.doorState
		if door_state != null && !animation_player.is_playing():
			if door_state == "OPEN":
				sprite.set_frame(door_opened_frame)
			else:
				sprite.set_frame(door_closed_frame)


#func _on_state_update(state):
#	if state.door:
#		var animation_node = get_node(animation_node_path)
#		var sprite_node = get_node(sprite_node_path)
#		var door_state = state.door.doorState
#		if door_state != null && !animation_node.is_playing():
#			if door_state == "OPEN":
#				sprite_node.set_frame(door_opened_frame)
#			else:
#				sprite_node.set_frame(door_closed_frame)
#				