extends Control

var category: String

func _ready():
	$Container/VContainer/Stats.autowrap_mode = 2

func _process(_delta):
	if category == "swords":
		$Container/VContainer/Stats.text = "Swords are used to damage the enemies overtime!
		Damage per second: %s" % [
			PlayerVariables.damage_per_second,
		]
	elif category == "scrolls":
		var scrolls = find_children("Item*", "", true, false)
		var levels = scrolls.reduce(func(a, b): return b.level + a.level)
		scrolls.sort_custom(func(a, b): return b.level < a.level)
		var s = scrolls[0]
		$Container/VContainer/Stats.text = "%s
		Scrolls bought: %s
		" % [
			"You haven't bought any scroll for the time being!" if s.level <= 0 else "You bought %s %s time%s so far!" % [s.i_name, s.level, "s" if s.level > 1 else ""],
			levels,
		]
	elif category == "potions":
		$Container/VContainer/Stats.text = "Note that new potions will be revealed as you gain levels!
		Active potions: %s" % [
			len(find_children("Item*", "", true, false).filter(func(p): return p.level > 0)),
		]
