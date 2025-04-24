extends DialogueScript


func _dialogue_process() -> void:
	add_text(["[shake]八百标兵奔北坡，[/shake]", 0.25, "\n北坡炮兵并排跑。"]).set_direction(1)
	add_text(["[wave]炮兵怕把标兵碰，[/wave]", "\n标兵怕碰炮兵炮。"]).set_direction(2).set_gaps_time(0.25).set_name("label_01")
	close_label("label_01")

	#add_timer(0.5)
	add_text(["八百标兵奔北坡，北坡炮兵并排跑。"]).set_direction(3)
	add_text("炮兵怕把标兵碰，标兵怕碰炮兵炮。").set_direction(4).set_name("label_02")
	close_label("label_02")

	#add_timer(0.5)
	add_text("八百标兵奔北坡，北坡炮兵并排跑。\n炮兵怕把标兵碰，标兵怕碰炮兵炮。")\
		.set_popup_parent(get_data("container")).set_popup_label(false)

	add_script("res://addons/dialogue_manager/tester/script_sample.gd", _dialogue_data)
