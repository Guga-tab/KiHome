extends Control

@export var radius: float = 80.0
@export var dead_zone: float = 0.2
@export var show_on_desktop: bool = false

var _touch_index := -1
var _knob_offset := Vector2.ZERO


func _ready() -> void:
	visible = show_on_desktop or DisplayServer.is_touchscreen_available()


func _exit_tree() -> void:
	_release_actions()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and get_global_rect().grow(20.0).has_point(event.position):
			_touch_index = event.index
			_move_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_move_knob(event.position)


func _move_knob(touch_position: Vector2) -> void:
	var center := global_position + size / 2.0
	_knob_offset = (touch_position - center).limit_length(radius)
	_apply(_knob_offset / radius)
	queue_redraw()


func _reset() -> void:
	_touch_index = -1
	_knob_offset = Vector2.ZERO
	_release_actions()
	queue_redraw()


func _apply(direction: Vector2) -> void:
	if direction.length() < dead_zone:
		direction = Vector2.ZERO
	_set_axis("move_left", "move_right", direction.x)
	_set_axis("move_up", "move_down", direction.y)


func _set_axis(negative: String, positive: String, value: float) -> void:
	if value < 0.0:
		Input.action_press(negative, -value)
		Input.action_release(positive)
	elif value > 0.0:
		Input.action_press(positive, value)
		Input.action_release(negative)
	else:
		Input.action_release(negative)
		Input.action_release(positive)


func _release_actions() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)


func _draw() -> void:
	var center := size / 2.0
	draw_circle(center, radius, Color(1, 1, 1, 0.12))
	draw_arc(center, radius, 0.0, TAU, 48, Color(1, 0.85, 0.23, 0.5), 3.0)
	draw_circle(center + _knob_offset, radius * 0.4, Color(1, 0.85, 0.23, 0.7))
