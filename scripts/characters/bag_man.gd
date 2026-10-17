extends CharacterBody2D

@export var initial_speed: float = 90.0
@export var max_speed: float = 150.0
@export var speed_step_interval: float = 5.0
@export var speed_step_amount: float = 8.0
@export var time_to_appear: float = 5.0
@export var fade_duration: float = 2.0
@export var chase_delay: float = 1.5

const TRAIL_INTERVAL := 0.1

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var capture_area: Area2D = $CaptureArea

var player: Node2D
var _elapsed_time := 0.0
var _accumulated := 0.0
var _trail: Array[Vector2] = []
var _is_ready := false
var _is_active := false
var _has_captured := false
var _original_layer := 0


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	modulate.a = 0.0
	_original_layer = collision_layer
	collision_layer = 0
	capture_area.monitoring = false
	capture_area.body_entered.connect(_on_capture_area_body_entered)

	anim.animation = "down"
	anim.frame = 0

	await get_tree().physics_frame
	_is_ready = true

	await get_tree().create_timer(time_to_appear).timeout
	await _appear()


func _appear() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	await tween.finished

	collision_layer = _original_layer
	capture_area.monitoring = true
	_is_active = true


func _physics_process(delta: float) -> void:
	if not _is_ready or player == null or _has_captured:
		return

	_record_trail(delta)

	if not _is_active:
		return

	_elapsed_time += delta

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_position := agent.get_next_path_position()
		velocity = global_position.direction_to(next_position) * _current_speed()

	move_and_slide()
	_update_animation()


func _on_capture_area_body_entered(body: Node2D) -> void:
	if _has_captured or not body.is_in_group("player"):
		return
	_has_captured = true
	velocity = Vector2.ZERO
	get_tree().call_deferred("change_scene_to_file", "res://scenes/game_over.tscn")


func _update_animation() -> void:
	if velocity.length() < 1.0:
		anim.stop()
		return

	var anim_name: String
	if abs(velocity.x) > abs(velocity.y):
		anim_name = "right" if velocity.x > 0 else "left"
	else:
		anim_name = "down" if velocity.y > 0 else "up"

	anim.play(anim_name)


func _record_trail(delta: float) -> void:
	_accumulated += delta
	if _accumulated < TRAIL_INTERVAL:
		return
	_accumulated = 0.0
	_trail.append(player.global_position)

	var steps := int(chase_delay / TRAIL_INTERVAL)
	if _trail.size() > steps:
		agent.target_position = _trail.pop_front()


func _current_speed() -> float:
	var steps := int(_elapsed_time / speed_step_interval)
	return minf(initial_speed + steps * speed_step_amount, max_speed)
