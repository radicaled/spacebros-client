extends Node

#const Client = preload("client.gd");

var client
var networkHub

func connectToServer():
	networkHub = get_node("/root/network_hub")
	client = get_node("/root/client")
	client.connect(client.CONNECTED, self, "_on_connection")
	client.connect(client.MESSAGE_RECEIVED, self, "_on_message")
	client.connectToGameServer("127.0.0.1", 3030)

func _on_connection():
	print("CONNECTED")
	client.send({ "@class" : "spacebros.networking.Messages$Login", "data": "" })
	
# handler to text messages
func _on_message(msg):
	pass

