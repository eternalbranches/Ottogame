extends StaticBody2D
var hp := 3
var damaged := preload ("res://Assets/Tiles/texture gray scale.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func on_hit(damage):
	hp -= damage
	if hp < 2:
		$Sprite.texture = damaged
	if hp < 0:
		queue_free()
	
