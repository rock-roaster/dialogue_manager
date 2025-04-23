extends Control


@onready var dialogue_layer: DialogueLayer = $DialogueLayer


func _ready() -> void:
	dialogue_layer._popup_position = Vector2(1920, 1080) * 0.5
	Dialogue.load_dialogue_script("res://addons/dialogue_manager/tester/script_sample.gd")
