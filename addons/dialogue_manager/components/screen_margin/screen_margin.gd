extends VBoxContainer


func change_bar_size(value: float) -> void:
	var bar_size_tweener: Tween = create_tween().set_parallel()
	bar_size_tweener.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	bar_size_tweener.tween_property($TopBar, ^"custom_minimum_size:y", value, 0.25)
	bar_size_tweener.tween_property($BottomBar, ^"custom_minimum_size:y", value, 0.25)
	await bar_size_tweener.finished
