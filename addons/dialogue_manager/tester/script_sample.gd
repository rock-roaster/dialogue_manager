extends DialogueScript


func _dialogue_process() -> void:
	add_text(["[shake]八百标兵奔北坡，[/shake]", 0.25, "\n北坡炮兵并排跑。"], true).set_direction(1)
	add_text(["[wave]炮兵怕把标兵碰，[/wave]", "\n标兵怕碰炮兵炮。"]).set_direction(2).set_gaps_time(0.25)

	#add_timer(0.5)
	add_text([
		"八百标兵奔北坡，",
		"北坡炮兵并排跑。",
		], true).set_direction(3)

	add_text("炮兵怕把标兵碰，标兵怕碰炮兵炮。").set_direction(4)

	#add_timer(0.5)
	add_text("八百标兵奔北坡，北坡炮兵并排跑。\n炮兵怕把标兵碰，标兵怕碰炮兵炮。")
	add_script("res://addons/dialogue_manager/tester/script_sample.gd", _dialogue_data)
