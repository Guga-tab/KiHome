extends Node

@onready var button: Button = $Button


func _ready() -> void:
	AudioManager.play_music()
	button.pressed.connect(_on_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		AudioManager.play_click()
		_on_button_pressed()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
