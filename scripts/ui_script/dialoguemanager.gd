extends Control
onready var background = $"%Background"
onready var text_label = $"%Textfield"
onready var avatar_left = $"%Avatar_Left"
onready var avatar_right = $"%Avatar_Right"
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

func _input(event):
	if Input.is_action_just_pressed("advance_slide"):
		if _current_slide_index < current_dialogue.dialog_slides.size() -1:
			_current_slide_index += 1
			show_slide()
		else: # _runtime_data.current_gameplay_state == Enums.GameplayState.IN_DIALOG:
			GameEvents.emit_signal("dialog_finished")
			visible = false


#export(NodePath) onready var _dialog_text = get_node(_dialog_text) as Label
#export(NodePath) onready var _avatar = get_node(_avatar) as TextureRect
#export(Resource) var _current_dialogue_tres = _current_dialogue_tres as Dialogue
#export(Resource) var _runtime_data = _runtime_data as RuntimeData
#
#var _current_slide_index := 0
#func _ready():
#	_avatar.texture = _current_dialogue_tres.avatar_texture
#	show_slide()
#
#	GameEvents.connect("dialog_initiated", self, "on_dialog_initiated")
#	GameEvents.connect("dialog_finished", self, "on_dialog_finished")
#func _input(event):
#	if Input.is_action_just_pressed("advance_slide"):
#		if _current_slide_index < _current_dialogue_tres.dialog_slides.size() -1:
#			_current_slide_index += 1
#			show_slide()
#		elif _runtime_data.current_gameplay_state == Enums.GameplayState.IN_DIALOG:
#			GameEvents.emit_signal("dialog_finished")
#
#func show_slide() -> void:
#	_dialog_text.text = _current_dialogue_tres.dialog_slides[_current_slide_index]
#
#func on_dialog_initiated(dialogue : Dialogue) -> void:
#	_runtime_data.current_gameplay_state = Enums.GameplayState.IN_DIALOG
#	_current_dialogue_tres = dialogue
#	_current_slide_index = 0
#	_avatar.texture = dialogue.avatar_texture
#	show_slide()
#	visible = true
#
#func on_dialog_finished() -> void:
#	_runtime_data.current_gameplay_state = Enums.GameplayState.FREEWALK
#	visible = false
