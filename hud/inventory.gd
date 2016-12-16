extends GridContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var slot_one = get_node("PanelContainer/ButtonGroup/HBoxContainer/Button")
onready var slot_two = get_node("PanelContainer/ButtonGroup/HBoxContainer/Button 2")
onready var slot_three = get_node("PanelContainer/ButtonGroup/HBoxContainer/Button 3")
onready var slot_four = get_node("PanelContainer/ButtonGroup/HBoxContainer/Button 4")

const CURRENT_SLOT = 0
const MAX_SLOTS = 4

var slots = []
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	slots = [slot_one, slot_two, slot_three, slot_four]

func add_to_inventory(entity_node):
	if CURRENT_SLOT >= MAX_SLOTS:
		return
	var slot = slots[CURRENT_SLOT]
	
	slot.set_text(entity_node.get_entity_name())
	entity_node.hide()
	
	CURRENT_SLOT = CURRENT_SLOT + 1
	
	