
extends Node

var client
var connected = false

const _prefix = "spacebros.networking.Messages$"

const CONNECTED = "connected"
const DISCONNECTED = "disconnected"

const LOGIN = "Login"
const LOGIN_SUCCESS = "LoginSuccess"
const SYNCHRONIZE_REQUEST = "SynchronizeRequest"
const CREATE_ENTITY = "CreateEntity"
const DELETE_ENTITY = "DeleteEntity"
const SET_CAMERA    = "SetCamera"
const MOVE_DIRECTION = "MoveDirection"
const MOVE_TO_POSITION = "MoveToPosition"
const TEXT_MESSAGE = "TextMessage"
const INTERACTION = "Interaction"
const UPDATE_GRAPHIC = "UpdateGraphic"
const ANIMATE = "Animate"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	add_user_signal(CONNECTED)
	add_user_signal(DISCONNECTED)

	add_user_signal(LOGIN)
	add_user_signal(LOGIN_SUCCESS)

	add_user_signal(CREATE_ENTITY)
	add_user_signal(DELETE_ENTITY)
	add_user_signal(SET_CAMERA)
	add_user_signal(MOVE_DIRECTION)
	add_user_signal(MOVE_TO_POSITION)
	add_user_signal(TEXT_MESSAGE)
	add_user_signal(UPDATE_GRAPHIC)
	add_user_signal(ANIMATE)


func set_client(client_instance):
	client = client_instance
	client.connect(client.CONNECTED, self, "_on_connection")
	client.connect(client.DISCONNECTED, self, "_on_disconnection")

# Non-network related members

func get_connected():
	return connected

# High level commands

func login(player_data):
	send({ "playerName": player_data.name, "data": "" }, LOGIN)

func synchronize_request():
	send({}, SYNCHRONIZE_REQUEST)

func move_player(direction):
	send({ "direction": direction }, MOVE_DIRECTION)

func speak(msg):
	send({ "message": msg, "textType": "SPEAK" }, TEXT_MESSAGE)

func interact(entity_id, action):
	send({ "entityId": entity_id, "action": action }, INTERACTION)

# Low level commands

func send(data, type):
	var classProperty = _prefix + type
	data["@class"] = classProperty
	client.send(data)

# Callbacks for connection / disconnection
func _on_connection():
	connected = true
	emit_signal(CONNECTED)

func _on_disconnection():
	connected = false
	emit_signal(DISCONNECTED)

# Sort out which message came in and call the appropriate listener.
func _on_message(msg):
	var json = Dictionary()
	json.parse_json(msg)
	# What kind of message is it?
	var message_name = json['@class']
	var indexOfPrefix = message_name.find(_prefix)
	if (indexOfPrefix != 0):
		print("UNKNOWN MESSAGE: " + msg)
	var short_name = message_name.right(_prefix.length())
	print("received msg" + message_name)
	emit_signal(short_name, json)


