extends StaticBody2D

export var key = "orange_keycard"
export var close := false
export var trap := false

func _ready():
	if close == true:
		set_collision_layer_bit(0,1)
		set_collision_mask_bit(1,1)
		

func _on_Area2D_body_entered(_body):
	if CharacterSave.save_dict["keycards"].has(key) and close == true:
		$AnimationPlayer.play("Open")
		
		
func closed():
	set_collision_layer_bit(0, 1)
	close = true
func open():
	set_collision_layer_bit(0, 0)
	close = false


func _on_Area2D_body_exited(body):
	if close == false:
		$AnimationPlayer.play("Close")
