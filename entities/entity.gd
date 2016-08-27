# This is an entity. It's got default behaviors.

extends Area2D

signal clicked(event)

var entity_id

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON:
		emit_signal("clicked", event)

func set_entity_id(entity_id):
	self.entity_id = entity_id

func get_entity_id():
	return self.entity_id