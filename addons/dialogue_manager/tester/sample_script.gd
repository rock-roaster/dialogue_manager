extends DialogueScript


func _dialogue_process() -> void:
	var layer: DialogueLayer = get_data("layer") as DialogueLayer
	var character_01: Character = get_data("char_01") as Character
	var character_02: Character = get_data("char_02") as Character
	var push_point_01: Control = get_data("node_01") as Control
	var push_point_02: Control = get_data("node_02") as Control
	var push_point_03: Control = get_data("node_03") as Control
	var set_speaking_character: Callable = get_data("call_01") as Callable

	add_callable(character_01.change_body_alpha.bind(1.0))
	add_callable(character_02.change_body_alpha.bind(1.0), true, false)

	add_callable(set_speaking_character.bind(character_01))
	add_callable(character_01.change_brightness.bind(1.0))
	add_text("八百标兵奔北坡，北坡炮兵并排跑。").set_direction(3)

	add_callable(set_speaking_character.bind(character_02))
	add_callable(character_01.change_brightness.bind(0.5))
	add_callable(character_02.change_brightness.bind(1.0))
	add_text("炮兵怕把标兵碰，标兵怕碰炮兵炮。").set_direction(4)\
		.set_gaps_time(0.25).set_name("label_01")
	close_label("label_01")

	add_callable(layer.set_popup_parent.bind(push_point_01))
	add_callable(set_speaking_character.bind(character_01))

	add_callable(character_01.change_expression.bind("坏笑"))
	add_callable(character_01.change_brightness.bind(1.0))
	add_callable(character_02.change_brightness.bind(0.5))
	add_text(["[shake]八百标兵奔北坡，[/shake]", 0.25, "\n北坡炮兵并排跑。"]).set_direction(2)

	add_callable(layer.set_popup_parent.bind(push_point_02))
	add_callable(set_speaking_character.bind(character_02))

	add_callable(character_01.change_expression.bind("普通"))
	add_callable(character_02.change_expression.bind("坏笑"))
	add_callable(character_01.change_brightness.bind(0.5))
	add_callable(character_02.change_brightness.bind(1.0))
	add_text(["[wave]炮兵怕把标兵碰，[/wave]", "\n标兵怕碰炮兵炮。"]).set_direction(1)\
		.set_gaps_time(0.25).set_name("label_02")
	add_callable(character_02.change_expression.bind("普通"))
	close_label("label_02")

	add_callable(layer.set_popup_parent.bind(layer))
	add_callable(set_speaking_character.bind(null))

	add_callable(character_02.change_brightness.bind(0.5))
	add_text(["八百标兵奔北坡，北坡炮兵并排跑。", 0.25, "\n炮兵怕把标兵碰，标兵怕碰炮兵炮。"])\
		.set_popup_parent(push_point_03).set_label_bubble(false).set_ms_per_char(10.0)

	add_callable(character_01.change_body_alpha.bind(0.0))
	add_callable(character_02.change_body_alpha.bind(0.0), true)
	add_text("八百标兵奔北坡，北坡炮兵并排跑。\n炮兵怕把标兵碰，标兵怕碰炮兵炮。").set_ms_per_char(0.0)

	close_label()
	add_script("res://addons/dialogue_manager/tester/sample_script.gd", _dialogue_data)
