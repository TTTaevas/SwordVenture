extends TextureButton

signal buy

var psed := false
var i_name: String
var current_dps := 0
var dps: int
var price: int
var level := 0

func _ready():
	$Item.text = i_name

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
		$Stats.size = $Stats.get_theme_font("font").get_string_size($Stats.text)
		$Stats.position.x = $Shop_button.position.x + $Shop_button.size.x + 10
		$Stats.position.y = $Shop_button.position.y + 10
