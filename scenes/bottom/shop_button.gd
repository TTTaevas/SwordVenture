extends TextureButton

signal buy(item)

# Universal
var psed := false
var i_name: String
var i_description: String
var category: String
var price: int

# Swords
var current_dps := 0
var dps: int
var original_dps: int
var level := 0

# Potions
var duration: int
var duration_left := 0
var effect: Callable
var expired_effect: Callable

func _ready():
	$Item.text = i_name
	$Description.text = i_description
	original_dps = dps

func _process(_delta):
	if PlayerVariables.gold < price or duration_left > 0 or level + 1 > PlayerVariables.level:
		disabled = true
	elif disabled == true:
		disabled = false
	
	$Price.text = "%s: %s" % ["Buy" if level == 0 else "Upgrade", price]
	$Price.size = $Price.get_theme_font("font").get_string_size($Price.text)
	
	$Item.position.x = (size.x / 2) - ($Item.size.x / 2)
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Price.position.x = (size.x / 2) - ($Price.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Price.position.x + $Price.size.x + 12
	
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
		if category == "swords":
			$Stats.text = "Once equipped, it is able to deal %s damage per second!" % dps
		else:
			$Stats.text = ""
	else:
		if category == "swords":
			$Stats.text = "Does %s dps, will do %s if you upgrade it! Requires Level %s." % [current_dps, dps, level + 1]
		else:
			$Stats.text = "%s left!" % translate_time(duration_left)
	
	$Description.size = $Description.get_theme_font("font").get_string_size($Description.text)
	$Description.position.x = size.x + 10
	$Description.position.y = 15
	
	$Stats.size = $Stats.get_theme_font("font").get_string_size($Stats.text)
	$Stats.position.x = size.x + 10
	$Stats.position.y = 35

func _pressed():
	level += 1
	if category == "swords":
		buy.emit({"name": i_name, "price": price, "category": category, "dps": dps, "equipped": false})
		price = ceil(price * 1.07)
		current_dps = dps
		dps += original_dps
	elif category == "potions":
		price = ceil(price * 8.60)
		duration_left = duration
		effect.call()
		for i in duration_left:
			await get_tree().create_timer(1).timeout
			duration_left -= 1
			if i + 1 == duration:
				expired_effect.call()
				level -= 1

func translate_time(seconds: int):
	var m := 0
	var s = 0
	
	var i = seconds
	while i >= 60:
		m += 1
		i -= 60
	while i > 0:
		s += 1
		i -= 1
	
	s = ("0%s" % s) if s < 10 else s 
	return "%s:%s" % [m, s]

