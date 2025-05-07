extends Control


@onready var dialogue_layer: DialogueLayer = $DialogueLayer
@onready var option_manager: OptionManager = $DialogueLayer/OptionManager


func _ready() -> void:
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"dialogue_layer": dialogue_layer,
			"background": $DialogueLayer/Background,
			"screen_margin": $DialogueLayer/ScreenMargin,
			"call_01": add_option,
		}
	)


func add_option() -> void:
	option_manager.add_main_option()
	option_manager.add_custom_button("重新加载脚本", func():
		_ready()
		Dialogue.get_next_line()
	)
	option_manager.add_button("进入下级菜单", add_option_02, false)
	option_manager.add_long_press_button("退出示例场景", get_tree().quit)
	option_manager.set_button_vertical()


func add_option_02() -> void:
	option_manager.add_sub_option()
	option_manager.add_button("返回上级菜单")
	option_manager.add_button("进入下级菜单", add_option_02, false)
	option_manager.set_button_vertical(-1)
