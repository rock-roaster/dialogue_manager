extends Control


func _ready() -> void:
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"dialogue_layer": $DialogueLayer,
			"node_01": $DialogueLayer/Contents/BottomBar/Panel,
			"call_01": change_bar_size,
		}
	)


func change_bar_size(value: float) -> void:
	var bar_size_tweener: Tween = create_tween().set_parallel()
	bar_size_tweener.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	bar_size_tweener.tween_property($DialogueLayer/Contents/TopBar, ^"custom_minimum_size:y", value, 0.25)
	bar_size_tweener.tween_property($DialogueLayer/Contents/BottomBar, ^"custom_minimum_size:y", value, 0.25)
	await bar_size_tweener.finished
