extends Control

@onready var candy_label: Label = $CandyLabel
@onready var buttons := [$PlayAgain, $Quit]

var _selected := 0


func _ready() -> void:
	AudioManager.play_end_jingle()
	candy_label.text = "Candies: %d" % GameState.candies

	for i in buttons.size():
		var button: BaseButton = buttons[i]
		button.focus_mode = Control.FOCUS_NONE
		button.pivot_offset = button.size / 2.0
		button.mouse_entered.connect(_select.bind(i))

	_select(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		AudioManager.play_click()
		_select(_selected + 1)
	elif event.is_action_pressed("ui_up"):
		AudioManager.play_click()
		_select(_selected - 1)
	elif event.is_action_pressed("ui_accept"):
		buttons[_selected].pressed.emit()


func _select(index: int) -> void:
	_selected = wrapi(index, 0, buttons.size())
	for i in buttons.size():
		var button: BaseButton = buttons[i]
		var is_selected := i == _selected
		button.modulate = Color(0.788, 0.788, 0.788, 0.525) if is_selected else Color(0.737, 0.737, 0.737, 0.0)
		button.scale = Vector2.ONE * (1.08 if is_selected else 1.0)


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_title.tscn")
