extends Light2D


export var light = "white"
export var flashing = false
export var flickering = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if light == "red":
		color = Color(1,0,0)
	if flashing == true:
		get_node("AnimationPlayer").play("Flashing")
	if flickering == true:
		get_node("AnimationPlayer").play("Flickering")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
