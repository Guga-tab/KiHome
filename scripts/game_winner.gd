extends Control

@onready var candy_label: Label = $CandyLabel


func _ready() -> void:
	candy_label.text = "Candies: %d" % GameState.doces
	AudioManager.play_end_jingle()   # para a música e a risada, toca o happy_halloween
	candy_label.text = "Doces coletados: %d" % GameState.doces


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_title.tscn")
