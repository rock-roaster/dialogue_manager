extends TextureRect
class_name Background


const BLUR_SHADER: ShaderMaterial = preload(
	"res://addons/dialogue_manager/theme/shader/simple_blur.tres")

var _blur_rect: ColorRect
var _tween_blur: Tween
var _tween_brightness: Tween


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT, true)
	set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
	set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	z_index = -1

	_build_node_structure()


func _build_node_structure() -> void:
	_blur_rect = ColorRect.new()
	_blur_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	_blur_rect.z_index = 1
	_blur_rect.material = BLUR_SHADER
	add_child(_blur_rect)


func get_texture_rect(texture2d: Texture2D) -> TextureRect:
	var new_texture_rect: TextureRect = TextureRect.new()
	new_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	new_texture_rect.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
	new_texture_rect.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	new_texture_rect.set_texture(texture2d)
	return new_texture_rect


func change_texture(texture2d: Texture2D, time: float = 0.4) -> void:
	var new_texture_rect: TextureRect = get_texture_rect(texture2d)
	new_texture_rect.modulate.a = 0.0
	add_child(new_texture_rect)
	await tween_canvas_alpha(new_texture_rect, 1.0, time)
	set_texture(texture2d)
	new_texture_rect.queue_free()


func change_background(file_path: String, time: float = 0.4) -> void:
	var next_texture: Texture2D = ResourceLoader.load(file_path, "Texture2D")
	if next_texture == null: return
	await change_texture(next_texture, time)


func clear_texture(time: float = 0.4) -> void:
	var new_texture_rect: TextureRect = get_texture_rect(texture)
	add_child(new_texture_rect)
	set_texture(null)
	await tween_canvas_alpha(new_texture_rect, 0.0, time)
	new_texture_rect.queue_free()


func change_blur_amount(value: float, time: float = 0.4) -> void:
	var current_value: float = get_shader_amount()
	if _tween_blur: _tween_blur.kill()
	_tween_blur = create_tween()
	_tween_blur.tween_method(set_shader_amount, current_value, value, time)
	await _tween_blur.finished


func change_brightness(value: float, time: float = 0.4) -> void:
	if _tween_brightness: _tween_brightness.kill()
	_tween_brightness = create_tween()
	_tween_brightness.tween_property(self, ^"modulate:v", value, time)
	await _tween_brightness.finished


func tween_canvas_alpha(canvas: CanvasItem, alpha: float, time: float = 0.4) -> void:
	var tween_alpha: Tween = canvas.create_tween()
	tween_alpha.tween_property(canvas, ^"modulate:a", alpha, time)
	await tween_alpha.finished


func get_shader_amount() -> float:
	var shader_material: ShaderMaterial = _blur_rect.material as ShaderMaterial
	return shader_material.get_shader_parameter(&"blur_amount")


func set_shader_amount(value: float) -> void:
	var shader_material: ShaderMaterial = _blur_rect.material as ShaderMaterial
	return shader_material.set_shader_parameter(&"blur_amount", value)
