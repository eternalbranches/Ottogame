extends CanvasLayer

onready var HPBar = get_node("HPBar")
#var max_hp := 3
#var current_hp := 3

func _ready():
	pass # Replace with function body.


func HPChange(current_HP):
#	if value > 0:
#		if current_hp > max_hp:
#			current_hp += value
#	if value < 0:
#		if current_hp > 0:
#			current_hp -= value
			
	match current_HP:
		0: HPBar.texture = load("res://Assets/UI/GUI/png3.png")
		1: HPBar.texture = load("res://Assets/UI/GUI/healthbar2.png")
		2: HPBar.texture = load("res://Assets/UI/GUI/healthbar.png")
		3: HPBar.texture = load("res://Assets/UI/GUI/healthbar empty.png")


func _on_Player_HPchange(current_HP):
	match current_HP:
		0: HPBar.texture = load("res://Assets/UI/GUI/png3.png")
		1: HPBar.texture = load("res://Assets/UI/GUI/healthbar2.png")
		2: HPBar.texture = load("res://Assets/UI/GUI/healthbar.png")
		3: HPBar.texture = load("res://Assets/UI/GUI/healthbar empty.png")
