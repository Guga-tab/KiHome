extends Node


func _ready() -> void:
	AudioManager.play_end_jingle()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		AudioManager.play_click()
		_on_play_again_pressed()


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
