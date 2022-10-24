extends KinematicBody2D
var current_direction := "L"
var velocity := Vector2.ZERO
var speed := 100
var state := "idle"
var current_hp := 10
var dead := false
var active := false
var gravity := 500


func _ready() -> void:
	$Label.text == state
	
func _physics_process(delta : float) -> void:
	state_manager(delta)

func _process(delta):
	$Label.text == state


func state_manager(delta) -> void:
	call(state+"_state", delta)
	
	
func idle_state(delta) -> void:
	pass
	
func death_state(delta) -> void:
	velocity.x = 0
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
func crawl_state(delta) -> void:
	velocity.y += gravity * delta
	if is_on_floor():
		if current_direction == "L":
			velocity.x = -50
		else:
			velocity.x = 50
	velocity = move_and_slide(velocity, Vector2.UP)
		
func change_state(new_state : String) -> void:
	#print( state, new_state)
	if state != "death":
		state = new_state
		
func on_hit(damage, _origin, enemy_pos) -> void:
	if state != "death":
		current_hp -= damage
		flash()
	
	if current_hp <= 0:
			on_death()
		
func on_death() -> void:
	change_state("death")
	dead = true
	set_collision_layer_bit(2, 0)
	set_collision_mask_bit(1,0)
	$AnimationPlayer.play("Death_" + current_direction)
	$Floor.stop()
	visible = false
	
	
func flash():
	$Sprite.material.set_shader_param("flash_modifier", 0.4)
	$FlashTimer.start()

func _on_FlashTimer_timeout() -> void:
	$Sprite.material.set_shader_param("flash_modifier", 0)


func _on_Detect_body_entered(body):
	if active == true:
		if body.is_in_group("Insect") == false:
			if state == "idle":
				$AnimationPlayer.play("Hatch_" + current_direction)
				$Floorcheck.enabled
				$Floor.start()
			
func player_enters_range(activate : bool) -> void:
	if activate == true:
		active = true


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Hatch_R", "Hatch_L":
			change_state("crawl")


func _on_Timer_timeout():
	pass # Replace with function body.


func _on_Floor_timeout():
	if is_on_floor():
		if $Floorcheck.is_colliding() == false:
			print("change")
			if current_direction == "L":
				current_direction = "R"
			else:
				current_direction = "L"
		elif is_on_wall():
			if current_direction == "L":
				current_direction = "R"
			else:
				current_direction = "L"
		$AnimationPlayer.play("Crawl_"+current_direction)
