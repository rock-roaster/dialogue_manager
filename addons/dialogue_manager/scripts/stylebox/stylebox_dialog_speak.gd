extends StyleBoxDialogVoice
class_name StyleBoxDialogSpeak


enum ArrowSide{UP, RIGHT, DOWN, LEFT}

@export var arrow_side: ArrowSide = ArrowSide.DOWN
@export var arrow_width: float = 12.0
@export var arrow_height: float = 24.0


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	var points: PackedVector2Array = get_draw_points(rect)
	insert_arrow(points, rect)
	draw_points(to_canvas_item, points)


func insert_arrow(points: PackedVector2Array, rect: Rect2) -> void:
	var center: Vector2 = rect.get_center()

	var side_index: int = int(arrow_side)
	var start_index: int = corner_point_count * (side_index + 1) + side_index
	var end_index: int = (start_index + 1) % points.size()

	var start_position: Vector2 = points[start_index]
	var end_position: Vector2 = points[end_index]
	var mid_position: Vector2 = start_position + (end_position - start_position) * 0.5

	var point1: Vector2 = mid_position + (end_position - mid_position).normalized() * arrow_width
	var point2: Vector2 = mid_position + (mid_position - center).normalized() * arrow_height
	var point3: Vector2 = mid_position + (start_position - mid_position).normalized() * arrow_width

	points.insert(start_index + 1, point1)
	points.insert(start_index + 1, point2)
	points.insert(start_index + 1, point3)
