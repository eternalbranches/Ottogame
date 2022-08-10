extends StaticBody2D

export var key = "orange_keycard"
export var close := false
export var trap := false

func _ready():
	if close == true:
		set_collision_layer_bit(0,1)
		#set_collision_mask_bit(1,1)
		

func _on_Area2D_body_entered(_body) -> void:
	if CharacterSave.save_dict["keycards"].has(key) and close == true:
		$AnimationPlayer.play("Open")
		
		
func closed() -> void:
	set_collision_layer_bit(0, 1)
	close = true
	print(close)
func open() -> void:
	set_collision_layer_bit(0, 0)
	close = false
	print(close)


func _on_Area2D_body_exited(_body):
	if close == false:
		$AnimationPlayer.play("Close")
