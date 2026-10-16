extends CharacterBody2D

@export var velocidade_inicial: float = 90.0
@export var velocidade_maxima: float = 200.0
@export var tempo_ate_maximo: float = 60.0
@export var tempo_para_aparecer: float = 5.0
@export var duracao_fade: float = 2.0
@export var atraso_perseguicao: float = 1.5

const INTERVALO_RASTRO := 0.1

@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_captura: Area2D = $AreaCaptura

var player: Node2D
var _tempo := 0.0
var _acumulado := 0.0
var _rastro: Array[Vector2] = []
var _pronto := false
var _ativo := false
var _capturou := false
var _layer_original := 0


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	# Começa invisível, sem colisão com o jogador e sem capturar
	modulate.a = 0.0
	_layer_original = collision_layer
	collision_layer = 0
	area_captura.monitoring = false
	area_captura.body_entered.connect(_on_area_captura_body_entered)

	# Animação inicial
	anim.animation = "down"
	anim.frame = 0

	await get_tree().physics_frame
	_pronto = true

	await get_tree().create_timer(tempo_para_aparecer).timeout
	await _aparecer()


func _aparecer() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duracao_fade)
	await tween.finished

	collision_layer = _layer_original
	area_captura.monitoring = true
	_ativo = true


func _physics_process(delta: float) -> void:
	if not _pronto or player == null or _capturou:
		return

	_registrar_rastro(delta)

	if not _ativo:
		return

	_tempo += delta

	if agente.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var proximo := agente.get_next_path_position()
		velocity = global_position.direction_to(proximo) * _velocidade_atual()

	move_and_slide()
	_atualizar_animacao()


func _on_area_captura_body_entered(body: Node2D) -> void:
	if _capturou or not body.is_in_group("player"):
		return
	_capturou = true
	velocity = Vector2.ZERO
	get_tree().call_deferred("change_scene_to_file", "res://scenes/game_over.tscn")


func _atualizar_animacao() -> void:
	if velocity.length() < 1.0:
		anim.stop()
		return

	var nome: String
	if abs(velocity.x) > abs(velocity.y):
		nome = "right" if velocity.x > 0 else "left"
	else:
		nome = "down" if velocity.y > 0 else "up"

	anim.play(nome)


func _registrar_rastro(delta: float) -> void:
	_acumulado += delta
	if _acumulado < INTERVALO_RASTRO:
		return
	_acumulado = 0.0
	_rastro.append(player.global_position)

	var passos := int(atraso_perseguicao / INTERVALO_RASTRO)
	if _rastro.size() > passos:
		agente.target_position = _rastro.pop_front()


func _velocidade_atual() -> float:
	var t := clampf(_tempo / tempo_ate_maximo, 0.0, 1.0)
	return lerpf(velocidade_inicial, velocidade_maxima, t)
