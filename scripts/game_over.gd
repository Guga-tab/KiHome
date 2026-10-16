extends Node

@onready var button: Button = $Button

func _ready() -> void:
	AudioManager.play_end_jingle() 
	

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
