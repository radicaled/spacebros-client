# This scene is the main play scene, it's full of naked women and jungle dancers... I guess.
extends Node2D

const TILE_WIDTH = 32
const TILE_HEIGHT = 32

var global
var entity_hub
var network_hub
var entity_scene_mapper

var camera_target

onready var action_bar = get_node("Camera2D/Action Bar")
onready var chat_window = get_node("Camera2D/Chat Window")

func _ready():
	var global = get_node("/root/global")
	entity_hub = global.entity_hub
	network_hub = global.network_hub
	entity_scene_mapper = global.entity_scene_mapper

	network_hub.connect(network_hub.CONNECTED, self, '_on_connection')
	network_hub.connect(network_hub.CREATE_ENTITY, self, '_on_create_entity')
	network_hub.connect(network_hub.DELETE_ENTITY, self, '_on_delete_entity')
	network_hub.connect(network_hub.SET_CAMERA, self, '_on_set_camera')
	network_hub.connect(network_hub.MOVE_TO_POSITION, self, '_on_move_to_position')
	network_hub.connect(network_hub.TEXT_MESSAGE, self, '_on_text_message')

	camera_target = get_node("Camera2D").get_pos()
	set_process(true)
	set_process_input(true)

func _process(delta):
	var camera = get_node("Camera2D")
	
	if camera_target != camera.get_pos():
		var lerpy = camera.get_pos().linear_interpolate(camera_target, delta)
		camera.set_pos(lerpy)


func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.is_action_pressed("game_select"):
			pass
		if event.is_action("game_interact"):
			var action_mode = action_bar.get_action_mode()
			print("I am going to " + str(action_mode) + " at this")
		
	if event.type == InputEvent.KEY:
		if !chat_window.has_focus():
			if event.is_action_pressed("player_move_up"):
				move('NORTH')
			if event.is_action_pressed("player_move_down"):
				move('SOUTH')
			if event.is_action_pressed("player_move_right"):
				move('EAST')
			if event.is_action_pressed("player_move_left"):
				move('WEST')
			if event.is_action_pressed("text_submit"):
				chat_window.call_deferred('focus_chat_input')

# Network callbacks

# This is more like "on reconnection"
func _on_connected():
	network_hub.login(global.player_data)

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
	var desired_position = Vector2(msg.position.x * TILE_WIDTH, msg.position.y * TILE_HEIGHT)
	camera_target = desired_position

func _on_move_to_position(msg):
	var entity_node = entity_hub.get_entity(msg.entityId)
	if entity_node:
		entity_node.set_pos(Vector2(msg.position.x * TILE_WIDTH, msg.position.y * TILE_HEIGHT))
		entity_node.set_z(msg.position.z)

func _on_text_message(msg):
	var text = msg.message
	chat_window.append_chat_text(text)
	if msg.textType == "SPEAK" && msg.entityId:
		# Let's display this over the entity's head in a richtext label
		var speech_bubble_scene = preload("res://fx/speech_bubble.tscn")
		var speech_bubble = speech_bubble_scene.instance()
		var node = entity_hub.get_entity(msg.entityId)
		var existing_speech_bubble = node.get_node("Speech Bubble")
		if existing_speech_bubble:
			node.remove_child(existing_speech_bubble)
		node.add_child(speech_bubble)
		# Probable dimensions: 32px by 32px.
		# Above head: -32px
		# Slightly centered: -16px
		# TODO: stop doing this!
		text = text.split(':')[1]
		# TODO: stop doing this, too
		var new_pos = Vector2(-64, -64)
		# This is OK, I guess
		speech_bubble.set_pos(new_pos)
		speech_bubble.display_text(text)



# Helper Functions

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

func move(direction):
	network_hub.move_player(direction)

# UI callbacks

func _on_Chat_Window_text_submitted( text ):
	network_hub.speak(text)
