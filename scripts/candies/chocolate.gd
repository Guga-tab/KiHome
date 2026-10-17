extends Area2D

@export_flags_2d_physics var obstacle_mask: int = 1
@export var clear_radius: float = 16.0
@export var min_player_distance: float = 150.0
@export var attempts: int = 30

var _is_respawning := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _is_respawning or not body.is_in_group("player"):
		return
	body.candies_collected += 1
	get_tree().call_group("game", "add_candy")
	_respawn(body.global_position)


func _respawn(player_pos: Vector2) -> void:
	_is_respawning = true
	await get_tree().physics_frame

	var all_nodes := get_tree().get_nodes_in_group("spawn_zones")
	var zones: Array = []
	for node in all_nodes:
		if node is Control:
			zones.append(node)
		else:
			push_warning("Wrong node in 'spawn_zones': %s" % node.get_path())

	if zones.is_empty():
		push_warning("No valid nodes in the 'spawn_zones' group.")
		_is_respawning = false
		return

	for i in attempts:
		var r: Rect2 = zones.pick_random().get_global_rect()
		var candidate := Vector2(
			randf_range(r.position.x, r.end.x),
			randf_range(r.position.y, r.end.y)
		)
		if candidate.distance_to(player_pos) < min_player_distance:
			continue
		if _is_free(candidate):
			global_position = candidate
			break

	_is_respawning = false



func _is_free(pos: Vector2) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = clear_radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, pos)
	query.collision_mask = obstacle_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()
