extends Node

#const Client = preload("client.gd");

var client
var network_hub
var entity_hub
var entity_scene_mapper

var player_data = {}

func _ready():
	entity_hub = get_node("/root/entity_hub")
	network_hub = get_node("/root/network_hub")
	client = get_node("/root/client")
	entity_scene_mapper = load("res://lib/entity_scene_mapper.gd").new()

func switch_scene():
	pass

func connectToServer(player_data):
	self.player_data = player_data
	network_hub.set_client(client)
	network_hub.connect(network_hub.LOGIN_SUCCESS, self, "_on_login_success")
	client.connect(client.CONNECTED, self, "_on_connection")
	client.connect(client.DISCONNECTED, self, "_on_disconnection")
	client.connect(client.MESSAGE_RECEIVED, network_hub, "_on_message")
	client.connectToGameServer("127.0.0.1", 3030)

# Helpers

func entity_pos_to_vector2():
	pass

# Network callbacks

func _on_connection():
	print("CONNECTED")
	network_hub.login(player_data)

func _on_login_success(msg):
	print("LOGIN SUCCESS")
	get_tree().change_scene("res://screens/play_scene.tscn")
	network_hub.synchronize_request()

func _on_disconnection():
	print("DISCONNECTED")
