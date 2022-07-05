extends Node

signal hp_change
signal energy_change


func emit_signal_hp_change(current_hp : float, max_hp : float) -> void:
	emit_signal("hp_change", current_hp, max_hp)
	
func emit_signal_energy_change(current_energy : float, max_energy : float) -> void:
	emit_signal("energy_change", current_energy, max_energy)
