extends Node

# Experimental:
# TCP client to connect to spacebros-server
# Seeing how the development flow is in Godot v. raw libgdx
# Can't use websockets in Godot because [stupid reason here]
#
# Rationale: server side stuff is fine, gamedev stuff is difficult to achieve because
# I am a lazy slacker. Also, if this is open source, I want it as easy as possible for other
# non-slackers to contribute.

var connecting = false
var connected = false
var streamPeer = StreamPeerTCP.new()
var buffer = []

func _ready():
	set_process(true)

func _process(delta):
	_check_connection()
	if connected:
		if streamPeer.get_available_bytes() > 0:
			var msg = get_waiting_message()
		# TODO: parse packets
		# TODO: trigger callbacks
		# TODO: get bare bones visualization working. FREE AT LAST, FREE AT LAST.
	

func connectToGameServer(host, port):
	streamPeer.set_big_endian(true)
	streamPeer.connect(host, port)
	connecting = true
	
	if streamPeer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		print("Connection established.")
		# Execute evil wizardry here
		send({ "HELLO": "WORLD" }.to_json())
		# Ensuring that it trims correctly
		send({ "TAKE": "TWO" }.to_json())
		print("sending data...?")
	
func send(data):
	# Format:
	# "MSG" - ASCII (77, 83, 71)
	# Length: UInt, Big Endian
	# Data: utf-8 string
	var rawArray = data.to_utf8()
	streamPeer.put_8(77) # M
	streamPeer.put_8(83) # S
	streamPeer.put_8(71) # G
	streamPeer.put_u32(rawArray.size()) # Length of Message in bytes
	streamPeer.put_partial_data(rawArray) # Actual data	
	
	print("Sent data: " + data)

func _get_waiting_message

func _check_connection():
	if streamPeer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		connecting = false
		connected = true
	if streamPeer.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		connected = false
		connecting = true
		# print("Status: Connecting")
	if streamPeer.get_status() == StreamPeerTCP.STATUS_ERROR:
		connected = false
		connecting = false
		# print("Status: Error")
	if streamPeer.get_status() == StreamPeerTCP.STATUS_NONE:
		connected = false
		connecting = false
		# print("Status: Disconnected")
	