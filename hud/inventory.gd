extends PanelContainer

func _ready():
	pass

func add_to_inventory(entity_node):
	entity_node.hide()
	var tex = get_frame_texture(entity_node.get_node("Sprite"))
	get_node("ItemList").add_item(entity_node.get_entity_name(), tex)

func get_frame_texture(sprite):
	var n = sprite
	var tex = n.get_texture()
	var at = AtlasTexture.new()
	var frame = n.get_frame()
	
	var width = tex.get_width() / n.get_hframes()
	var height = tex.get_height() / n.get_vframes()
	var x = (frame * width) % tex.get_width()
	var y = ((frame * width) / tex.get_width() * height)
	
	var region = Rect2(x, y, width, height)
	at.set_atlas(tex)
	at.set_region(region)
	return at
