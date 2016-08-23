# Entity Hub: tracks known entities, so they can be referred to by entity id
extends Node

# a map in the form of int -> Node,
# where int is the entity id, and Node is its node in the scene graph

var entities = {}

func _ready():
	pass

func add_entity(entityId, node):
	entities[entityId] = node

func remove_entity(entityId, node):
	entities.erase(entityId)


