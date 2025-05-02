extends DialogueScript


func _dialogue_process() -> void:
	var char_path_01: String = "res://addons/dialogue_manager/tester/sample_character/帕秋莉/帕秋莉.tres"
	var char_path_02: String = "res://addons/dialogue_manager/tester/sample_character/小恶魔/小恶魔.tres"

	System.resource_manager.preload_resource(char_path_01)
	System.resource_manager.preload_resource(char_path_02)

	var dialogue_layer: DialogueLayer = get_data("dialogue_layer") as DialogueLayer
	var background: Background = get_data("background") as Background
	var push_point_01: Control = get_data("node_01") as Control
	var chang_bar_size: Callable = get_data("call_01") as Callable

	var add_character: Callable = dialogue_layer.add_character
	var character_call: Callable = dialogue_layer.character_call
	var remove_character: Callable = dialogue_layer.remove_character
	var set_popup_parent: Callable = dialogue_layer.set_popup_parent
	var set_speaking_character: Callable = dialogue_layer.set_speaking_character

	add_callable(add_character, ["帕秋莉", char_path_01, Vector2(480.0, 180.0)])
	add_callable(add_character, ["小恶魔", char_path_02, Vector2(1440.0, 180.0)])

	add_callable(chang_bar_size, 72.0)

	add_callable(background.change_background, "background_01.png")
	add_callable(character_call, ["帕秋莉", "change_body_alpha", 1.0])
	add_callable(character_call, ["小恶魔", "change_body_alpha", 1.0], true, false)

	add_callable(set_speaking_character, "帕秋莉")
	add_callable(set_popup_parent, [null, Vector2(0.0, -5.0)])

	add_text("八百标兵奔北坡，北坡炮兵并排跑。")

	add_callable(background.change_blur_amount, 1.0)
	add_callable(set_speaking_character, "小恶魔")
	add_callable(set_popup_parent, [null, Vector2(0.0, +5.0)])

	add_text("炮兵怕把标兵碰，标兵怕碰炮兵炮。").set_name("label_01")
	close_label("label_01")

	add_callable(background.change_background, "background_02.png")
	add_callable(character_call, ["帕秋莉", "change_expression", "坏笑"])
	add_callable(set_speaking_character, ["帕秋莉", Vector2(240.0, 0.0)])

	add_text(["[shake]八百标兵奔北坡，[/shake]", 0.25, "\n北坡炮兵并排跑。"])

	add_callable(background.change_blur_amount, 0.0)
	add_callable(character_call, ["帕秋莉", "change_expression"])
	add_callable(character_call, ["小恶魔", "change_expression", "坏笑"])
	add_callable(set_speaking_character, ["小恶魔", Vector2(-240.0, 200.0)])

	add_text(["[wave]炮兵怕把标兵碰，[/wave]", 0.25, "\n标兵怕碰炮兵炮。"]).set_name("label_02")
	close_label("label_02")

	add_callable(background.change_background, "background_03.png")
	add_callable(character_call, ["小恶魔", "change_expression"])
	add_callable(character_call, ["帕秋莉", "change_expression", "坏笑"])
	add_callable(set_speaking_character, ["帕秋莉", Vector2(240.0, 0.0)])

	add_text(["八百标兵奔北坡，北坡炮兵并排跑。", "\n炮兵怕把标兵碰，标兵怕碰炮兵炮。"
		]).set_gaps_time(0.25)

	add_callable(character_call, ["帕秋莉", "change_expression"])
	add_callable(character_call, ["小恶魔", "change_expression", "坏笑"])
	add_callable(set_speaking_character, ["小恶魔", Vector2(-240.0, 0.0)])

	add_text(["八百标兵奔北坡，北坡炮兵并排跑。", "\n炮兵怕把标兵碰，标兵怕碰炮兵炮。"
		]).set_gaps_time(0.25)

	add_callable(background.clear_texture)
	add_callable(character_call, ["小恶魔", "change_expression"])
	add_callable(set_speaking_character, null)

	add_text(["八百标兵奔北坡，北坡炮兵并排跑。", 0.25, "炮兵怕把标兵碰，标兵怕碰炮兵炮。"
		]).set_popup_parent(push_point_01).set_label_bubble(false).set_ms_per_char(10.0)

	add_callable(chang_bar_size, 0.0)
	add_callable(character_call, ["帕秋莉", "change_body_alpha", 0.0])
	add_callable(character_call, ["小恶魔", "change_body_alpha", 0.0]).set_await_call()

	add_callable(remove_character, "帕秋莉")
	add_callable(remove_character, "小恶魔")

	add_text(["八百标兵奔北坡，北坡炮兵并排跑。", "\n炮兵怕把标兵碰，标兵怕碰炮兵炮。"
		]).set_ms_per_char(0.0)
	close_label()

	add_script("res://addons/dialogue_manager/tester/sample_script.gd", _dialogue_data)
