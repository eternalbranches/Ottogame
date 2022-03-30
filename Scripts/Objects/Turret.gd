extends StaticBody2D
onready var player = get_node("../../Player/Player")

var player_in_range
#var player_in_sight
#var player_seen

var can_shoot := false
var current_hp := 2

var state = "idle"
var initialized := false
export var sprite_pointing := "S"

func _ready():
	match sprite_pointing:
		"S":
			pass
		"N":
			$Sprite.flip_v = false
		"E":
			$Sprite.rotation_degrees = -90
		"W":
			$Sprite.rotation_degrees = 90

func _process(_delta):
	$Label.text = state
	match state:
		"idle":
			pass
		"sight":
			sightcheck()
		"shoot":
			sightcheck()
			if initialized == false:
				$ShootCD.start()
				initialized = true
			if can_shoot == true:
				var skill = load("res://Scenes/Abilities/Bullet.tscn")
				var skill_instance = skill.instance()
				skill_instance.rotation = get_angle_to(player.get_global_position())
				skill_instance.position = get_position()                   #get_node("TurnAxis/CastPoint").get_global_position()
				skill_instance.enemyposx = position.x
				skill_instance.origin = "Enemy"
				#skill_instance.node_reference = get_path()
				$SFXPLayer.play()
				get_parent().add_child(skill_instance)
				can_shoot = false
	
func sightcheck():
	#var raycasting_player = player.position - Vector2(0, 0)
	var space_state = get_world_2d().direct_space_state
	var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
	if sight_check:
		#print(sight_check)
		if sight_check.collider.name == "Player":
			if state != "shoot":
				state = "shoot"
		else:
			initialized = false
			state = "sight"
			$ShootCD.stop()

func _on_Range_body_entered(_body):
	if state == "idle":
		state = "sight"
		player_in_range = true


func _on_Range_body_exited(_body):
	if state == "shoot":
		$ChangeState.start()
	else:
		player_in_range = false
		initialized = false
		if state != "death":
			state = "idle"
		$ShootCD.stop()

func _on_ShootCD_timeout():
	can_shoot = true
	
func on_hit(damage, _origin, _enemyposx):
	if state != "death":
		current_hp -= damage
	if current_hp <= 0:
			on_death()
			
func on_death():
	state = "death"
	$RemoveTimer.start()
	


func _on_ChangeState_timeout():
	if $Range.get_overlapping_bodies().empty():
		if state != "death":
			state = "idle"
			$ShootCD.stop()
			player_in_range = false
			initialized = false


func _on_RemoveTimer_timeout():
	queue_free()
