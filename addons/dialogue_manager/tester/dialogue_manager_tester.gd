extends Control


@onready var option_manager: OptionManager = $DialogueLayer/OptionManager


func _ready() -> void:
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"dialogue_layer": $DialogueLayer,
			"background": $DialogueLayer/Background,
			"screen_margin": $DialogueLayer/ScreenMargin,
			"call_01": add_option,
		}
	)


func add_option() -> void:
	option_manager.add_main_option(true)
	option_manager.add_custom_button("重新加载脚本", func():
		_ready()
		Dialogue.get_next_line()
	)
	option_manager.add_long_press_button("退出示例场景", get_tree().quit)
	option_manager.set_button_vertical()
