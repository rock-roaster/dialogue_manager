@tool
extends EditorPlugin


const SYSTEM_NAME: String = "Dialogue"
const SYSTEM_PATH: String = "res://addons/dialogue_manager/dialogue_manager.gd"

const SETTING_SCRIPT: Script = preload("res://addons/dialogue_manager/setting.gd")
const SETTING_INFO_DICT: Dictionary[StringName, Dictionary] = SETTING_SCRIPT.SETTING_INFO_DICT


## 在插件运行时添加项目设置
func _enter_tree() -> void:
	_add_project_settings()
	add_autoload_singleton(SYSTEM_NAME, SYSTEM_PATH)
	ProjectSettings.save()


## 在启用插件时添加脚本模板
func _enable_plugin() -> void:
	_add_template()


## 在禁用插件时恢复项目配置
func _disable_plugin() -> void:
	remove_autoload_singleton(SYSTEM_NAME)
	_remove_project_settings()
	ProjectSettings.save()
	_remove_template()


## 添加配置脚本中的设置项
func _add_project_settings() -> void:
	for setting_dict in SETTING_INFO_DICT.values():
		_add_setting_dict(setting_dict)


## 移除配置脚本中的设置项
func _remove_project_settings() -> void:
	for setting_dict in SETTING_INFO_DICT.values():
		_remove_setting_dict(setting_dict)


## 使用hint_dictionary添加选项
func _add_setting_dict(info_dict: Dictionary) -> void:
	var setting_name: String = info_dict["name"]
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, info_dict["default"])

	ProjectSettings.set_as_basic(setting_name, info_dict["basic"])
	ProjectSettings.set_initial_value(setting_name, info_dict["default"])
	ProjectSettings.add_property_info(info_dict)


## 使用hint_dictionary移除选项
func _remove_setting_dict(info_dict: Dictionary) -> void:
	var setting_name: String = info_dict["name"]
	if ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, null)


func _add_template() -> void:
	copy_dir("res://addons/dialogue_manager/script_templates", "res://script_templates")
	hide_dir("res://script_templates")


func _remove_template() -> void:
	remove_dir("res://script_templates")


func copy_dir(from: String, to: String) -> void:
	if not from.ends_with("/"): from += "/"
	var dir_access: DirAccess = DirAccess.open(from)
	if dir_access == null: return
	dir_access.set_include_hidden(true)
	if not to.ends_with("/"): to += "/"
	dir_access.make_dir_recursive(to)
	for file_name in dir_access.get_files():
		dir_access.copy(from + file_name, to + file_name)
	for dir_name in dir_access.get_directories():
		copy_dir(from + dir_name, to + dir_name)


func remove_dir(path: String) -> void:
	if not path.ends_with("/"): path += "/"
	var dir_access: DirAccess = DirAccess.open(path)
	if dir_access == null: return
	dir_access.set_include_hidden(true)
	for file_name in dir_access.get_files():
		dir_access.remove(file_name)
	for dir_name in dir_access.get_directories():
		remove_dir(path + dir_name)
	dir_access.remove(".")


func hide_dir(path: String) -> void:
	if not path.ends_with("/"): path += "/"
	if not DirAccess.dir_exists_absolute(path): return
	FileAccess.open(path + ".gdignore", FileAccess.WRITE).store_8(0)
