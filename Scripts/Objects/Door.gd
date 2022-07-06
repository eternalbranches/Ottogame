extends StaticBody2D

export var key = "orange_keycard"
export var closed := false

func _ready():
	if closed == true:
		set_collision_layer_bit(0,1)
		set_collision_mask_bit(1,1)
		

func _on_Area2D_body_entered(_body):
	if CharacterSave.save_dict["keycards"].has(key):
		visible = false
		set_collision_layer_bit(0, 0)
		set_collision_mask_bit(1, 0)
