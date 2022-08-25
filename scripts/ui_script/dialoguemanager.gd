extends Control
onready var background = $"%Background"
onready var text_label = $"%Textfield"
onready var avatar_left = $"%Avatar_Left"
onready var avatar_right = $"%Avatar_Right"
onready var animation_left = $"%Anim_Left"
onready var animation_right = $"%Anim_Right"
onready var background_right = $"%Background_Right"
onready var background_left = $"%Background_Left"
onready var timer_left = $"%Timer_Left"
onready var timer_right = $"%Timer_Right"
export(Resource) var current_dialogue = current_dialogue as Dialogue
#export(Resource) var _runtime_data = _runtime_data as RuntimeData

var _current_slide_index := 0

func _ready():
	GameEvents.connect("dialogue_entered", self, "on_dialog_entered")
	GameEvents.connect("dialogue_finished", self, "on_dialog_finished")
	show_slide()


func show_slide() -> void:
	text_label.bbcode_text = current_dialogue.dialog_slides[_current_slide_index]
	background.texture = current_dialogue.highlight[_current_slide_index]
	avatar_left.texture = current_dialogue.avatar_left[_current_slide_index]
	avatar_right.texture = current_dialogue.avatar_right[_current_slide_index]
	background_left.texture = current_dialogue.background_left[_current_slide_index]
	background_right.texture = current_dialogue.background_right[_current_slide_index]
	animation_left.play(current_dialogue.animation_left[_current_slide_index])
	animation_right.play(current_dialogue.animation_right[_current_slide_index])
	timer_left.start(current_dialogue.left_time[_current_slide_index])
	timer_right.start(current_dialogue.right_time[_current_slide_index])

func _input(event):
	if Input.is_action_just_pressed("advance_slide"):
		if _current_slide_index < current_dialogue.dialog_slides.size() -1:
			_current_slide_index += 1
			show_slide()
		else: # _runtime_data.current_gameplay_state == Enums.GameplayState.IN_DIALOG:
			GameEvents.emit_signal_dialogue_finished()
			visible = false


func _on_Timer_Left_timeout():
	animation_left.stop()


func _on_Timer_Right_timeout():
	animation_right.stop()
