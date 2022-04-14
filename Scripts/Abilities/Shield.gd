extends RigidBody2D
var direction := "W"
var origin

func _ready():
	print("spawned")
	$AnimationPlayer.play("Shield_"+direction)
	print(position)


func _on_Shield_body_entered(body):
	pass # Replace with function body.
