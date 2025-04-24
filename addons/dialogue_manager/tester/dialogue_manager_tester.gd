extends Control


func _ready() -> void:
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/script_sample.gd",
		{
			"container": $Panel
		}
	)
