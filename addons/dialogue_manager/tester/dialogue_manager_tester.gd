extends Control


func _ready() -> void:
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"dialogue_layer": $DialogueLayer,
			"node_01": $DialogueLayer/ScreenMargin/BottomBar/Panel,
			"call_01": $DialogueLayer/ScreenMargin.change_bar_size,
		}
	)
