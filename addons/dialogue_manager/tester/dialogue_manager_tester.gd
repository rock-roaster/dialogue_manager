extends Control


func _ready() -> void:
	var dialogue_layer: DialogueLayer = $DialogueLayer
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"char_01": $Character1,
			"char_02": $Character2,
			"node_01": $Character1/Point1,
			"node_02": $Character2/Point2,
			"node_03": $Contents/BottomBar/Panel,
			"call_01": dialogue_layer.set_speaking_character,
			"call_02": change_bar_size
		}
	)


func change_bar_size(value: float) -> void:
	var bar_size_tweener: Tween = create_tween().set_parallel()
	bar_size_tweener.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	bar_size_tweener.tween_property($Contents/TopBar, "custom_minimum_size:y", value, 0.25)
	bar_size_tweener.tween_property($Contents/BottomBar, "custom_minimum_size:y", value, 0.25)
	await bar_size_tweener.finished
