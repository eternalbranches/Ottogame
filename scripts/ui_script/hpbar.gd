extends TextureProgress

func _ready():
	GameEvents.connect("hp_change", self, "hp_change")
func hp_change(current_hp : float, max_hp : float):
	var percantage_hp = (current_hp / max_hp) * 100
	value = percantage_hp
	
