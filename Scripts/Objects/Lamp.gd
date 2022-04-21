extends Light2D


export var light := "white"
export var flashing := false
export var flickering := false
export var lamp_texture := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	if light == "red":
		color = Color(1,0,0)
	if flashing == true:
		get_node("AnimationPlayer").play("Flashing")
	if flickering == true:
		get_node("AnimationPlayer").play("Flickering")
	if lamp_texture == 2:
		$Lamp.texture = load("res://Assets/Objects/light2.png")
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
