extends DialogueScript


func _dialogue_process() -> void:
	add_text("Hello World!")
	add_timer(0.5)
	add_callable(func(): print("Amigo!"))
