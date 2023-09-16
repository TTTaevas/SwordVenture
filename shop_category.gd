extends TextureButton

var cat_name: String
var icon: String
var normal_position: int
var required_level: int

func _ready():
	name = "Shop_category_%s" % cat_name
	$Icon.texture = load(icon if icon != "" else "res://sprites/icons/coin.png")
	normal_position = $Icon.position.y

func _process(_delta):
	$Icon.position.y = normal_position - 5 if button_pressed else normal_position

func _pressed():
	var parent = get_parent()
	if button_pressed and parent.name != "root":
		parent.find_child("Shop_selling_%s" % cat_name, false, false).show()
		var categories = parent.find_children("Shop_category*", "", false, false).filter(func(i): return i != self)
		for category in categories:
			if category.button_pressed:
				category.set_pressed_no_signal(false)
				parent.find_child("Shop_selling_%s" % category.cat_name, false, false).hide()
	else:
		parent.find_child("Shop_selling_%s" % cat_name, false, false).hide()

