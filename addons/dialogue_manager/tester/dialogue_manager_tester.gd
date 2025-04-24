extends Control


func _ready() -> void:
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/script_sample.gd",
		{
			"node_01": $Panel,
			"node_02": $Control,
		}
	)
