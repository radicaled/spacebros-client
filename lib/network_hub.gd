
extends Node

var client
const _prefix = "spacebros.networking.Messages$"

const LOGIN = "Login"
const CREATE_ENTITY = "CreateEntity"
const DELETE_ENTITY = "DeleteEntity"
const SET_CAMERA    = "SetCamera"
const MOVE_DIRECTION = "MoveDirection"
const MOVE_TO_POSITION = "MoveToPosition"
const TEXT_MESSAGE = "TextMessage"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	add_user_signal(LOGIN)
	add_user_signal(CREATE_ENTITY)
	add_user_signal(DELETE_ENTITY)
	add_user_signal(SET_CAMERA)
	add_user_signal(MOVE_DIRECTION)
	add_user_signal(MOVE_TO_POSITION)
	add_user_signal(TEXT_MESSAGE)

func set_client(client_instance):
	client = client_instance

func login():
	send({ "data": "" }, LOGIN)

func send(data, type):
	var classProperty = _prefix + type
	data["@class"] = classProperty
	client.send(data)

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
	emit_signal(short_name, json)


