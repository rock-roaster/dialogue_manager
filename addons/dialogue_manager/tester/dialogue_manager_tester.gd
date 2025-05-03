extends Control


func _ready() -> void:
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"dialogue_layer": $DialogueLayer,
			"background": $DialogueLayer/Background,
			"screen_margin": $DialogueLayer/ScreenMargin,
		}
	)
