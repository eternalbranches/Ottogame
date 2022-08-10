extends Label
func _ready():
	# warning-ignore:return_value_discarded
	GameEvents.connect("hp_change", self, "hp_change")
func hp_change(current_hp, _max_hp):
	text = str(ceil(current_hp))
