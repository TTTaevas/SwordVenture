extends TextureButton

signal buy(item)

var psed := false
var i_name: String
var i_description: String
var category: String
var current_dps := 0
var dps: int
var original_dps: int
var price: int
var level := 0

func _ready():
	$Item.text = i_name
	$Description.text = i_description
	original_dps = dps

func _process(_delta):
	if get_tree().root.get_node("Game").gold < price:
		disabled = true
	elif disabled == true:
		disabled = false
	
	$Item.position.x = (size.x / 2) - ($Item.size.x / 2)
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Price.position.x = (size.x / 2) - ($Price.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Price.position.x + $Price.size.x + 12
	
	$Price.text = "%s: %s" % ["Buy" if level == 0 else "Level up", price]
	
	if button_pressed and psed == false:
		psed = true
		var children := get_children().filter(func(i): return i.name != "Stats")
		for i in children:
			i.position.y += 5
	elif button_pressed == false and psed:
		psed = false
		var children := get_children().filter(func(i): return i.name != "Stats")
		for i in children:
			i.position.y -= 5
	
	if level < 1:
		$Stats.text = "Once equipped, it is able to deal %s damage per second!" % dps
	else:
		$Stats.text = "Currently does %s dps, will do %s if you level it up!" % [current_dps, dps]
	
	$Description.size = $Description.get_theme_font("font").get_string_size($Description.text)
	$Description.position.x = size.x + 10
	$Description.position.y = 15
	
	$Stats.size = $Stats.get_theme_font("font").get_string_size($Stats.text)
	$Stats.position.x = size.x + 10
	$Stats.position.y = 35

func _pressed():
	buy.emit({"name": i_name, "price": price, "category": category, "dps": dps, "equipped": false})
	price = ceil(price * 1.07)
	level += 1
	current_dps = dps
	dps += original_dps
