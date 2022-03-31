extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$LaserOn.start()

func _on_LaserOn_timeout():
	$Laser.set_is_casting(true)
	$LaserOff.start()


func _on_LaserOff_timeout():
	$Laser.set_is_casting(false)
	$LaserOn.start()
