
extends Node

const HUMAN = preload("res://entities/human.tscn")
const FLOORS = preload("res://entities/floors.tscn")
const PLAYER = HUMAN
const STRUCTURES = preload("res://entities/structure.tscn")
const WALLS = preload("res://entities/walls.tscn")
const SECURITY_DOORS = preload("res://entities/security_doors.tscn")
const COMMAND_DOORS = preload("res://entities/command_doors.tscn")
const BUTCHER_KNIFE = preload("res://entities/butcher_knife.tscn")

const ENTITY_TYPE_TO_SCENE_MAP = {
	"butcher_knife": BUTCHER_KNIFE,
	"Doorcomglass": COMMAND_DOORS,
	"Doorsecglass": SECURITY_DOORS,
	"human": HUMAN,
	"floors": FLOORS,
	"player": PLAYER,
	"structures": STRUCTURES,
	"walls": WALLS
}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func map(type):
	if !ENTITY_TYPE_TO_SCENE_MAP.has(type):
		print("UNKNOWN TYPE: " + str(type))
		return
	return ENTITY_TYPE_TO_SCENE_MAP[type]


