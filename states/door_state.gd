extends Node

export(int) var door_closed_frame = 0
export(int) var door_opened_frame = 0
onready var entity_node = get_node("..")
onready var animation_player = get_node("../AnimationPlayer")
onready var sprite = get_node("../Sprite")

func _ready():
	entity_node.connect("state_update", self, '_on_state_update')
	_on_state_update(entity_node.get_entity_state())

func _on_state_update(state):
	if state.door != null:
		var door_state = state.door.doorState
		if door_state != null && !animation_player.is_playing():
			if door_state == "OPEN":
				sprite.set_frame(door_opened_frame)
			else:
				sprite.set_frame(door_closed_frame)
