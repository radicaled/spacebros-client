# This is an entity. It's got default behaviors.

extends Area2D

signal clicked(event)
signal hover()
signal unhover()
signal state_update(state)

var entity_id
var entity_name
var entity_state = {}

onready var animation_player = get_node("AnimationPlayer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON:
		emit_signal("clicked", event)

func set_entity_name(name):
	entity_name = name

func get_entity_name():
	if not entity_name:
		return "Unknown Entity " + str(entity_id)
	return entity_name

func set_entity_id(entity_id):
	self.entity_id = entity_id

func get_entity_id():
	return self.entity_id

func set_entity_state(state):
	entity_state = state
	emit_signal("state_update", state)

func get_entity_state(state):
	return entity_state

func animate(animation_name):
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

func _on_entity_mouse_enter():
	emit_signal("hover")

func _on_entity_mouse_exit():
	emit_signal("unhover")
