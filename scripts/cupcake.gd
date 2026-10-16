extends Area2D

@export_flags_2d_physics var mascara_obstaculos: int = 1
@export var raio_livre: float = 16.0
@export var distancia_minima_player: float = 150.0
@export var tentativas: int = 30

var _reposicionando := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _reposicionando or not body.is_in_group("player"):
		return
	body.doces_coletados += 1
	_reposicionar(body.global_position)


func _reposicionar(pos_player: Vector2) -> void:
	_reposicionando = true
	await get_tree().physics_frame

	var zonas := get_tree().get_nodes_in_group("zonas_spawn")
	if zonas.is_empty():
		push_warning("Nenhuma zona no grupo 'zonas_spawn'.")
		_reposicionando = false
		return

	for i in tentativas:
		var r: Rect2 = zonas.pick_random().get_global_rect()
		var candidato := Vector2(
			randf_range(r.position.x, r.end.x),
			randf_range(r.position.y, r.end.y)
		)
		if candidato.distance_to(pos_player) < distancia_minima_player:
			continue
		if _esta_livre(candidato):
			global_position = candidato
			break

	_reposicionando = false


func _esta_livre(pos: Vector2) -> bool:
	var forma := CircleShape2D.new()
	forma.radius = raio_livre

	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, pos)
	consulta.collision_mask = mascara_obstaculos
	consulta.collide_with_bodies = true
	consulta.collide_with_areas = false

	return get_world_2d().direct_space_state.intersect_shape(consulta, 1).is_empty()
