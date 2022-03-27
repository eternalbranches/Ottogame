extends StaticBody2D

export var key = "orange"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(_body):
	if CharacterSave.save_dict["orange_keycard"] == true:
		visible = false
		set_collision_layer_bit(0, 0)
		set_collision_mask_bit(1, 0)
