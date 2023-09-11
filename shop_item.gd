extends Control

signal buy

var shop_entry = preload("res://shop_button.tscn")
var i_name = ""
var dps = 1
var price = 0

func _ready():
	var item := shop_entry.instantiate()
	item.connect("buy", purchase)
	item.find_child("Item").text = i_name
	add_child(item)

func _process(_delta):
	if get_parent().get_parent().gold < price:
		$Shop_button.disabled = true
	elif $Shop_button.disabled == true:
		$Shop_button.disabled = false
	
#	$Shop_button.position.x = $Border.size.x - $Border.position.x
#	print($Shop_button.position.x)

func purchase():
	buy.emit({"name": i_name, "dps": dps}, price)
	price = round(price * 1.5)
	dps *= 3
