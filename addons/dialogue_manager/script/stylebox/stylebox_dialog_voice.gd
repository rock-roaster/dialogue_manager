@tool
extends StyleBox
class_name StyleBoxDialogVoice


@export var corner_radius: float = 12.0
@export var corner_point_count: int = 8
@export var border_width: int = 1
@export var solid_color: Color = Color(Color.BLACK, 0.75)
@export var border_color: Color = Color.WHITE


func _init() -> void:
	content_margin_left = 24.0
	content_margin_right = 24.0
	content_margin_top = 8.0
	content_margin_bottom = 8.0


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	var points: PackedVector2Array = get_draw_points(rect)
	draw_points(to_canvas_item, points)


func draw_points(to_canvas_item: RID, points: PackedVector2Array) -> void:
	RenderingServer.canvas_item_add_polygon(to_canvas_item, points, PackedColorArray([solid_color]))
	RenderingServer.canvas_item_add_polyline(to_canvas_item, points, PackedColorArray([border_color]), border_width, true)


func get_corner_round_points(radius: float = corner_radius, count: int = corner_point_count) -> PackedVector2Array:
	var delta: float = PI * 0.5 / count
	var round_points: PackedVector2Array = PackedVector2Array()
	for i in range(count + 1):
		var position: Vector2 = Vector2(radius * cos(delta * i + PI), radius * sin(delta * i + PI))
		round_points.append(position)
	return round_points


func get_draw_points(rect: Rect2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	points.append(Vector2.ZERO)
	points.append(Vector2(rect.size.x, 0))
	points.append(rect.size)
	points.append(Vector2(0, rect.size.y))

	var radius: float = corner_radius
	var round_count: int = corner_point_count
	var round_points: PackedVector2Array = get_corner_round_points(radius, round_count)

	for i in range(4):
		var index: int = 3 - i
		var prev_point: Vector2 = points[index - 1]
		var curr_point: Vector2 = points[index]
		var next_point: Vector2 = points[(index + 1) % points.size()]
		var v_prev: Vector2 = (prev_point - curr_point).normalized() * radius
		var v_next: Vector2 = (next_point - curr_point).normalized() * radius
		points[index] = curr_point + v_prev

		var offset_matrix: Transform2D = Transform2D().rotated(PI * 0.5 * index).translated(curr_point + v_prev + v_next)
		var round_position: PackedVector2Array = offset_matrix * round_points
		round_position.remove_at(0)
		for pindex in round_position.size():
			var rev_index: int = round_position.size() - 1 - pindex
			points.insert(index + 1, round_position[rev_index])

	points.append(points[0])
	return points
