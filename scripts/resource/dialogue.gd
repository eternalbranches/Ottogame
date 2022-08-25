extends Resource

class_name Dialogue

export(Array, Texture) var avatar_right
#export (String, "Angry", "Happy", "Joyful", "Neutral", "Serious", "Tired", "Worried") var animation_right
export (Array, String, "Angry", "Happy", "Joyful", "Neutral", "Serious", "Tired", "Worried") var animation_right
export(Array, Texture) var background_right
export (Array, float) var right_time = []

export(Array, Texture) var avatar_left
export(Array, String, "Angry", "Happy", "Joyful", "Neutral", "Serious", "Tired", "Worried") var animation_left
#export (String, "Angry", "Happy", "Joyful", "Neutral", "Serious", "Tired", "Worried") var animation_left
export(Array, Texture) var background_left
export (Array, float) var left_time = []


export(Array, String, MULTILINE) var dialog_slides
export(Array, Texture) var highlight

