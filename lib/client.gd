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

var hasEmittedConnectionEvent = false
var hasEmittedDisconnectionEvent = true
var thread = Thread.new()
var mutex = Mutex.new()
var use_threads = false

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

func _threaded_emit(user_data):
	emit_signal(user_data.signal_type, user_data.msg)

func _run():
	_check_connection()
	if connected:
		if streamPeer.get_available_bytes() > 0:
			var msg = _get_waiting_message()
			emit_signal(MESSAGE_RECEIVED, msg)

func _run_in_thread(user_data):
	while true:
		_run()

func connectToGameServer(host, port):
	streamPeer.set_big_endian(true)
	streamPeer.connect(host, port)
	connecting = true
	
	if streamPeer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		print("Connection established.")
	
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
	var data = streamPeer.get_data(3)
	var header = RawArray(data[1]).get_string_from_ascii()
	if header == 'MSG':
		# loop until collected entire do-dawdle
		while true:
			if streamPeer.get_available_bytes() > 4:
				var expectedLength = streamPeer.get_u32()
				var data = streamPeer.get_data(expectedLength)
				return RawArray(data[1]).get_string_from_utf8()
	
func _check_connection():
	if streamPeer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		connecting = false
		connected = true
		if !hasEmittedConnectionEvent:
			hasEmittedConnectionEvent = true
			hasEmittedDisconnectionEvent = false
			emit_signal(CONNECTED)
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
		if !hasEmittedDisconnectionEvent:
			hasEmittedDisconnectionEvent = true
			hasEmittedConnectionEvent = false
			emit_signal(DISCONNECTED)
