extends TextureProgress

func _ready():
	# warning-ignore:return_value_discarded
	GameEvents.connect("energy_change", self, "energy_change")
func energy_change(current_energy : float, max_energy : float):
	var percantage_energy = (current_energy / max_energy) * 100
	value = percantage_energy