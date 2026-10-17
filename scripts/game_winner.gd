extends Control

@onready var candy_label: Label = $CandyLabel


func _ready() -> void:
	AudioManager.play_end_jingle()
	candy_label.text = "Candies: %d" % GameState.candies


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_title.tscn")
