# This scene is the main play scene, it's full of naked women and jungle dancers... I guess.
extends Node2D

const TILE_WIDTH = 32
const TILE_HEIGHT = 32

var global
var entity_hub
var network_hub
var entity_scene_mapper

var camera_target

var entities_near_mouse = []

var player_entity_id
var player_entity

onready var context_menu = get_node("Camera2D/Context Menu")

onready var action_bar = get_node("Camera2D/Action Bar")
onready var chat_window = get_node("Camera2D/Chat Window")
onready var inventory = get_node("Camera2D/Inventory")

func _ready():
	var global = get_node("/root/global")
	entity_hub = global.entity_hub
	network_hub = global.network_hub
	entity_scene_mapper = global.entity_scene_mapper

	network_hub.connect(network_hub.CONNECTED, self, '_on_connection')
	network_hub.connect(network_hub.CREATE_ENTITY, self, '_on_create_entity')
	network_hub.connect(network_hub.UPDATE_ENTITY, self, '_on_update_entity')
	network_hub.connect(network_hub.DELETE_ENTITY, self, '_on_delete_entity')
	network_hub.connect(network_hub.SET_CAMERA, self, '_on_set_camera')
	network_hub.connect(network_hub.SET_PLAYER_ENTITY, self, '_on_set_player_entity')
	network_hub.connect(network_hub.MOVE_TO_POSITION, self, '_on_move_to_position')
	network_hub.connect(network_hub.TEXT_MESSAGE, self, '_on_text_message')
	network_hub.connect(network_hub.ANIMATE, self, '_on_animate')

	camera_target = get_node("Camera2D").get_pos()

	set_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)

func _process(delta):
	var camera = get_node("Camera2D")
	
	if camera_target != camera.get_pos():
		var lerpy = camera.get_pos().linear_interpolate(camera_target, delta)
		camera.set_pos(lerpy)


func _input(event):
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

func _unhandled_input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		# TODO: FIX: accidentally selecting items underneath the cursor instead of the context menu
		if event.is_action_pressed("game_select"):
			context_menu.clear()
			var action_mode = action_bar.get_action_mode()
			var nodes = entities_near_mouse
			for node in nodes:
				context_menu.add_item(node.get_entity_name(), node.get_entity_id())
			
			if nodes.size() > 0:
				context_menu.set_pos(get_local_mouse_pos() + Vector2(15, 0))
				context_menu.show_modal()

		if event.is_action_pressed("game_interact"):
			var action_mode = action_bar.get_action_mode()
			var closet_node
			for node in entities_near_mouse:
				if not closet_node:
					closet_node = node
				else:
					if closet_node.get_z() <= node.get_z():
						closet_node = node
			if closet_node:
				var desc = str(closet_node.get_entity_id()) + " (" + str(closet_node.get_entity_name())  + ")"
				print("I am going to " + str(action_mode) + " this: " + desc)
				network_hub.interact(closet_node.get_entity_id(), action_mode)
			else:
				print("Nothing to " + str(action_mode) + " with or at")

# Network callbacks

# This is more like "on reconnection"
func _on_connected():
	network_hub.login(global.player_data)

func _on_create_entity(msg):
	var node = create_entity_node(msg)
	entity_hub.add_entity(msg['entityId'], node)
	if node:
		node.connect("clicked", self, "_on_entity_clicked", [node])
		node.connect("hover", self, "_on_entity_hover", [node])
		node.connect("unhover", self, "_on_entity_unhover", [node])
		add_child(node)

func _on_update_entity(msg):
	var entity_id = msg['entityId']
	var node = entity_hub.get_entity(entity_id)
	node.set_entity_state(msg.state)
	# TODO: need better alignment of "player entity" concept.
	# TODO: research player modelling in an ECS later
	# HACK: if we got an inventory state for a node that is us, then show that as our inventory.
	if entity_id == player_entity_id:
		var inventory_state = msg.state['inventory']
		if inventory_state != null:
			# What entities do we know about that exist in our inventory?
			for inventory_item_entity_id in inventory_state.contents:
				inventory.add_to_inventory(entity_hub.get_entity(inventory_item_entity_id))
				print("We have this:" + str(inventory_item_entity_id))

func _on_delete_entity(msg):
	var entity_id = msg['entityId']
	var node = entity_hub.get_entity(entity_id)
	entity_hub.remove_entity(entity_id, node)
	if node:
		remove_child(node)

func _on_set_camera(msg):
	var camera = get_node("Camera2D")
	var desired_position = Vector2(msg.position.x * TILE_WIDTH, msg.position.y * TILE_HEIGHT)
	camera_target = desired_position

func _on_set_player_entity(msg):
	var entity_id = msg.entityId
	player_entity_id = entity_id
	player_entity = entity_hub.get_entity(entity_id)
	print("WE ARE: " + str(entity_id))

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
		if node.has_node("Speech Bubble"):
			node.remove_child(node.get_node("Speech Bubble"))
		node.add_child(speech_bubble)
		# Probable dimensions: 32px by 32px.
		# Above head: -32px
		# Slightly centered: -16px
		# TODO: stop doing this!
		text = text.split(':')[1]

		var item_rect = node.get_item_and_children_rect()
		var speech_pos = Vector2(item_rect.pos.x, -item_rect.size.height)

		# This is OK, I guess
		speech_bubble.set_pos(speech_pos)
		speech_bubble.display_text(text)

func _on_animate(msg):
	var entity = entity_hub.get_entity(msg.entityId)
	entity.animate(msg.animation)

func _on_entity_clicked(event, node):
	pass

func _on_entity_hover(node):
	if (not node in entities_near_mouse):
		entities_near_mouse.append(node)

func _on_entity_unhover(node):
	if (node in entities_near_mouse):
		entities_near_mouse.erase(node)


# Helper Functions

func create_entity_node(msg):
	if msg['state'] != null && !msg.state.has('type'):
		print("Null object: " + str(msg))
		return
	var scene = entity_scene_mapper.map(msg.state.type.name)
	if !scene:
		return
	var node = scene.instance()
	var sprite = node.get_node("Sprite")
	node.set_pos(Vector2(msg.state.position.x * TILE_WIDTH, msg.state.position.y * TILE_HEIGHT))
	node.set_z(msg.state.position.z)
	if sprite:
		sprite.set_frame(msg.state.tileGraphic.tileId)
	node.set_entity_id(msg.entityId)
	node.set_entity_name(msg.state.name.name)
	node.set_entity_state(msg.state)
	return node

func move(direction):
	network_hub.move_player(direction)

# UI callbacks

func _on_Chat_Window_text_submitted( text ):
	network_hub.speak(text)
