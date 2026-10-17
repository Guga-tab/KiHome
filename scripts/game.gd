extends Node2D

const WINNER_SCENE := "res://scenes/game_winner.tscn"

var candies := 0
var stairs_open := false

@onready var candy_label: Label = $HUD/CandyLabel
@onready var timer_label: Label = $HUD/TimerLabel
@onready var game_timer: Timer = $GameTimer
@onready var stair_block_shape: CollisionShape2D = $StairBlock/CollisionShape2D
@onready var stairs_exit: Area2D = $StairsExit


func _ready() -> void:
	AudioManager.play_music()

	add_to_group("game")
	_update_candy_label()
	stair_block_shape.disabled = true
	game_timer.timeout.connect(_on_game_timer_timeout)
	stairs_exit.body_entered.connect(_on_stairs_body_entered)

	var laugh_timer := Timer.new()
	laugh_timer.one_shot = true
	add_child(laugh_timer)
	laugh_timer.timeout.connect(func():
		AudioManager.play_laugh()
		laugh_timer.start(randf_range(5.0, 15.0))
	)
	laugh_timer.start(randf_range(5.0, 20.0))


func _process(_delta: float) -> void:
	if not stairs_open:
		var t := int(ceil(game_timer.time_left))
		timer_label.text = "%02d:%02d" % [t / 60, t % 60]


func add_candy() -> void:
	candies += 1
	_update_candy_label()
	AudioManager.play_collect()


func _update_candy_label() -> void:
	candy_label.text = "Candies: %d" % candies


func _on_game_timer_timeout() -> void:
	stairs_open = true
	stair_block_shape.set_deferred("disabled", true)
	$StairBlock.hide()
	timer_label.text = "ESCAPE BY THE STAIRS!"


func _on_stairs_body_entered(body: Node) -> void:
	if stairs_open and body.is_in_group("player"):
		GameState.candies = candies
		get_tree().change_scene_to_file.call_deferred(WINNER_SCENE)
