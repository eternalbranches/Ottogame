extends Label
func _ready():
	GameEvents.connect("hp_change", self, "hp_change")
func hp_change(current_hp, _max_hp):
	text = str(ceil(current_hp))
