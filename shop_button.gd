extends TextureButton

var psed := false
var gold := 0
var price = 3

func _process(_delta):
	gold = get_parent().gold
	
	if gold < price:
		disabled = true
	elif disabled:
		disabled = false
	
	$Item.position.x = (size.x / 2) - ($Item.size.x / 2)
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Price.position.x = (size.x / 2) - ($Price.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Price.position.x + $Price.size.x + 12
	
	$Price.text = "Buy: %s" % price
	
	if button_pressed and psed == false:
		psed = true
		var children := get_children()
		for i in children:
			i.position.y += 5
	elif button_pressed == false and psed:
		psed = false
		var children := get_children()
		for i in children:
			i.position.y -= 5

func _pressed():
	print("aaaaa")
