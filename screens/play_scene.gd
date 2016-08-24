# This scene is the main play scene, it's full of naked women and jungle dancers... I guess.
extends Node2D

const TILE_WIDTH = 32
const TILE_HEIGHT = 32

var global
var entity_hub
var network_hub
var entity_scene_mapper

func _ready():
	var global = get_node("/root/global")
	entity_hub = global.entity_hub
	network_hub = global.network_hub
	entity_scene_mapper = global.entity_scene_mapper
	
	network_hub.connect(network_hub.CREATE_ENTITY, self, '_on_create_entity')
	network_hub.connect(network_hub.DELETE_ENTITY, self, '_on_delete_entity')
	network_hub.connect(network_hub.SET_CAMERA, self, '_on_set_camera')

func _on_create_entity(msg):
	var node = create_entity_node(msg)
	entity_hub.add_entity(msg['entityId'], node)
	if node:
		add_child(node)

func _on_delete_entity(msg):
	var entity_id = msg['entityId']
	var node = entity_hub[entity_id]
	entity_hub.remove_entity(entity_id, node)
	if node:
		remove_child(node)

func _on_set_camera(msg):
	var camera = get_node("Camera2D")
	camera.set_pos(Vector2(msg.position.x * TILE_WIDTH, msg.position.y * TILE_HEIGHT))

func create_entity_node(msg):
	var scene = entity_scene_mapper.map(msg.type)
	if !scene:
		return
	var node = scene.instance()
	var sprite = node.get_node("Sprite")
	node.set_pos(Vector2(msg.position.x * TILE_WIDTH, msg.position.y * TILE_HEIGHT))
	node.set_z(msg.position.z)
	if sprite:
		sprite.set_frame(msg.graphic.tileId)
	return node