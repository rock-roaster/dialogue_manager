extends Node
class_name LiteTimer


enum TimerMode {PROCESS, PHISICS_PROCESS}

var is_running: bool
var wait_time: float
var time_left: float
var process_callback: TimerMode

signal timeout


func _init(
	time: float = 1.0,
	timer_mode: int = TimerMode.PROCESS,
	) -> void:

	wait_time = time
	process_callback = timer_mode


func _process(delta: float) -> void:
	if process_callback != TimerMode.PROCESS: return
	if not is_running: return

	time_left -= delta
	if time_left <= 0.0:
		break_count_down()


func _physics_process(delta: float) -> void:
	if process_callback != TimerMode.PHISICS_PROCESS: return
	if not is_running: return

	time_left -= delta
	if time_left <= 0.0:
		break_count_down()


func count_down(time: float = wait_time) -> Signal:
	time_left = time
	is_running = true
	return timeout


func break_count_down() -> void:
	if not is_running: return
	is_running = false
	time_left = 0.0
	timeout.emit()
