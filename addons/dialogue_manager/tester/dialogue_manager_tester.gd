extends Control


func _ready() -> void:
	var dialogue_layer: DialogueLayer = $DialogueLayer

	dialogue_layer.add_character(
		"帕秋莉",
		"res://addons/dialogue_manager/tester/sample_character/帕秋莉/帕秋莉.tres",
		Vector2(480.0, 180.0),
	)

	dialogue_layer.add_character(
		"小恶魔",
		"res://addons/dialogue_manager/tester/sample_character/小恶魔/小恶魔.tres",
		Vector2(1440.0, 180.0),
	)

	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"dialogue_layer": dialogue_layer,
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
