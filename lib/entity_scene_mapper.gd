
extends Node

const ENTITY_TYPE_TO_SCENE_MAP = {
	"human": "res://entities/human.tscn",
	"floors": "res://entities/floors.tscn",
	"player": "res://entities/human.tscn",
	"structures": "res://entities/structure.tscn",
	"walls": "res://entities/walls.tscn"
}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func map(type):
	if !ENTITY_TYPE_TO_SCENE_MAP.has(type):
		print("UNKNOWN TYPE: " + type)
		return
	return ENTITY_TYPE_TO_SCENE_MAP[type]	


