extends Sprite


func _ready():
	# warning-ignore:return_value_discarded
	GameEvents.connect("hp_change", self, "hp_change")

func hp_change(current_hp : float, max_hp : float):
	var percantage_hp : float = (current_hp / max_hp) * 100
	print(percantage_hp)
	if percantage_hp > 80.0:
		frame = 0
	elif percantage_hp > 60.0:
		frame = 1
	elif percantage_hp > 40.0:
		frame = 2
	elif percantage_hp > 20.0:
		frame = 3
	else:
		frame = 4
