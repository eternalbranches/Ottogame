extends StaticBody2D

export var key = "orange"
export var closed := false


# Called when the node enters the scene tree for the first time.
func _ready():
	if closed == true:
		set_collision_layer_bit(0,1)
		set_collision_mask_bit(1,1)
		

func _on_Area2D_body_entered(_body):
	if CharacterSave.save_dict["orange_keycard"] == true:
		visible = false
		set_collision_layer_bit(0, 0)
		set_collision_mask_bit(1, 0)
