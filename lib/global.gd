extends Node

#const Client = preload("client.gd");

var client
var websocket

func connectToServer():
	#client = Client.new()
	client = get_node("/root/client")
	# websocket = preload("websocket.gd").new(self)
	# websocket.start('localhost',8080, 'gameStream')
	# websocket.set_reciever(self,'_on_message')
	# websocket.set_connection_established_reciever(self, '_on_connection')
	
	client.connectToGameServer("127.0.0.1", 3030)

func _on_connection():
	print("CONNECTED")
	var data = { "data": "foobar" }.to_json()
	websocket.send(data)
	print("Done?")
	
# handler to text messages
func _on_message(msg):
	print("MESSAGE RECEIVED")
	print(msg)

# handler to some button on you scene
func _on_some_button_released():
    websocket.send("Some short message here")