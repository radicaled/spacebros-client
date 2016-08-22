extends Node

#const Client = preload("client.gd");

var client
var network_hub

func _ready():
	network_hub = get_node("/root/network_hub")
	client = get_node("/root/client")

func switch_scene():
	pass

func connectToServer():
	network_hub.set_client(client)
	client.connect(client.CONNECTED, self, "_on_connection")
	client.connect(client.MESSAGE_RECEIVED, network_hub, "_on_message")
	client.connectToGameServer("127.0.0.1", 3030)

func _on_connection():
	print("CONNECTED")
	network_hub.login()
	
# handler to text messages
func _on_message(msg):
	pass

