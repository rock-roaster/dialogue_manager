extends RefCounted


const SETTING_DIALOGUE: String = "dialogue_manager/"

const SETTING_INFO_DICT: Dictionary[StringName, Dictionary] = {
	"log_history":
	{
		"name": SETTING_DIALOGUE + "log_history",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1, 100, or_greater",
		"basic": true,
		"default": 100,
	},

	"break_tweening":
	{
		"name": SETTING_DIALOGUE + "break_tweening",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"auto_advance_time":
	{
		"name": SETTING_DIALOGUE + "auto_advance_time",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0, 1.0, or_greater",
		"basic": true,
		"default": 0.25,
	},

	"msec_per_character":
	{
		"name": SETTING_DIALOGUE + "msec_per_character",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0, 100.0, or_greater",
		"basic": true,
		"default": 25.0,
	},
}


## 设置路径和字典名称里只要填对一个就能得到参数的傻瓜方法
static func get_setting_value(setting_name: StringName, default_value: Variant = null) -> Variant:
	var setting_dict: Dictionary = {}

	if SETTING_INFO_DICT.has(setting_name):
		setting_dict = SETTING_INFO_DICT.get(setting_name)
		setting_name = setting_dict.get("name")

	if setting_dict.is_empty():
		for dict in SETTING_INFO_DICT.values():
			if dict.get("name") == setting_name:
				setting_dict = dict
				break

	if setting_dict.has("default") && default_value == null:
		default_value = setting_dict.get("default")

	return ProjectSettings.get_setting(setting_name, default_value)
