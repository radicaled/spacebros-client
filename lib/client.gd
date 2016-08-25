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

var has_emitted_connection_event = false
var has_emitted_disconnection_event = true
var thread = Thread.new()
var mutex = Mutex.new()
var use_threads = true

const CONNECTED = "connected"
const DISCONNECTED = "disconnected"
const MESSAGE_RECEIVED = "message_received"

func _init():
	add_user_signal(CONNECTED)
	add_user_signal(DISCONNECTED)
	add_user_signal(MESSAGE_RECEIVED)

func _ready():
	if use_threads:
		if OK != thread.start(self, '_run_in_thread', null):
			print("client.gd: FAILED TO START THREAD")
	else:
		set_process(true)

func _process(delta):
	_run()

func _run():
	_check_connection()
	if connected:
		var msg = _get_waiting_message()
		call_deferred("emit_signal", MESSAGE_RECEIVED, msg)

func _run_in_thread(user_data):
	while true:
		_run()

func connectToGameServer(host, port):
	streamPeer.set_big_endian(true)
	streamPeer.connect(host, port)
	connecting = true
	
func send(data):
	mutex.lock()
	# Format:
	# "MSG" - ASCII (77, 83, 71)
	# Length: UInt, Big Endian
	# Data: utf-8 string
	var rawArray = data.to_json().to_utf8()
	streamPeer.put_8(77) # M
	streamPeer.put_8(83) # S
	streamPeer.put_8(71) # G
	streamPeer.put_u32(rawArray.size()) # Length of Message in bytes
	streamPeer.put_partial_data(rawArray) # Actual data
	
	mutex.unlock()
	print("Sent data: " + data.to_json())

func _get_waiting_message():
	# wait for a valid header...
	var header = streamPeer.get_string(3)
	if header == 'MSG':
		var expectedLength = streamPeer.get_u32()
		return streamPeer.get_utf8_string(expectedLength)
	else:
		print("UNKNOWN HEADER:" + str(header))

func _check_connection():
	if streamPeer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		connecting = false
		connected = true
		if !has_emitted_connection_event:
			has_emitted_connection_event = true
			has_emitted_disconnection_event = false
			call_deferred("emit_signal", CONNECTED)
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
		if !has_emitted_disconnection_event:
			has_emitted_disconnection_event = true
			has_emitted_connection_event = false
			call_deferred("emit_signal", DISCONNECTED)
