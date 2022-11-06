# Casts a laser along a raycast, emitting particles on the impact point.
# Use `is_casting` to make the laser fire and stop.
# You can attach it to a weapon or a ship; the laser will rotate with its parent.
extends RayCast2D

# Speed at which the laser extends when first fired, in pixels per seconds.
export var cast_speed := 7000.0
# Maximum length of the laser in pixels.
export var max_length := 1400.0
# Base duration of the tween animation in seconds.
export var growth_time := 0.1

# If `true`, the laser is firing.
# It plays appearing and disappearing animations when it's not animating.
# See `appear()` and `disappear()` for more information.
var is_casting := false setget set_is_casting

onready var fill := $Line2D
onready var tween := $Tween
onready var casting_particles := $CastingParticle
onready var collision_particles := $CollisionParticle
onready var beam_particles := $BeamParticle

onready var line_width: float = fill.width


func _ready() -> void:
	set_physics_process(false)
	fill.points[1] = Vector2.ZERO


func _physics_process(delta: float) -> void:
	cast_to = (cast_to + Vector2.RIGHT * cast_speed * delta).limit_length(max_length)
	cast_beam()

#func _unhandled_input(event: InputEvent) -> void:
	#set_is_casting(true)
	#print(is_casting)
	#if not event.is_action("ActionButton"):
	#	return
	#is_casting = event.is_action_pressed("ActionButton")
	
func set_is_casting(cast: bool) -> void:
	is_casting = cast

	if is_casting:
		cast_to = Vector2.ZERO
		fill.points[1] = cast_to
		appear()
	else:
		collision_particles.emitting = false
		disappear()

	set_physics_process(is_casting)
	beam_particles.emitting = is_casting
	casting_particles.emitting = is_casting


# Controls the emission of particles and extends the Line2D to `cast_to` or the ray's 
# collision point, whichever is closest.
func cast_beam() -> void:
	var cast_point := cast_to

	force_raycast_update()
	collision_particles.emitting = is_colliding()

	if is_colliding():
		if get_collider().is_in_group("Player"):
			get_collider().on_hit(1, "origin", position)
		
		cast_point = to_local(get_collision_point())
		collision_particles.global_rotation = get_collision_normal().angle()
		collision_particles.position = cast_point

	fill.points[1] = cast_point
	beam_particles.position = cast_point * 0.5
	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5


func appear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill, "width", 0, line_width, growth_time * 2)
	tween.start()


func disappear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill, "width", fill.width, 0, growth_time)
	tween.start()
