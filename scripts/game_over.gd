extends Node

@onready var button: Button = $Button

func _ready() -> void:
	pass
	

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_title.tscn")
