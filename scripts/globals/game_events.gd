extends Node

signal hp_change
signal energy_change
signal dialogue_entered
signal dialogue_finished

func emit_signal_hp_change(current_hp : float, max_hp : float) -> void:
	emit_signal("hp_change", current_hp, max_hp)
	
func emit_signal_energy_change(current_energy : float, max_energy : float) -> void:
	emit_signal("energy_change", current_energy, max_energy)
	
func emit_signal_dialogue_entered() -> void:
	emit_signal("dialogue_entered")
	
func emit_signal_dialogue_finished() -> void:
	emit_signal("dialogue_finished")
