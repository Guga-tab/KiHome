extends Node

const MUSIC := preload("res://sounds/is_anybody_home.wav")
const SFX_COLLECT := preload("res://sounds/item_collected.wav")
const SFX_CLICK := preload("res://sounds/button_press.wav")
const SFX_LAUGH := preload("res://sounds/evil_laugh.ogg")
const SFX_END := preload("res://sounds/happy_halloween.ogg")

var music_player: AudioStreamPlayer
var collect_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var laugh_player: AudioStreamPlayer
var end_player: AudioStreamPlayer


func _ready() -> void:
	music_player = _make_player(MUSIC, -5.0)
	collect_player = _make_player(SFX_COLLECT)
	click_player = _make_player(SFX_CLICK)
	laugh_player = _make_player(SFX_LAUGH)
	end_player = _make_player(SFX_END, -8.0)

	# Repete a música quando ela termina
	music_player.finished.connect(music_player.play)

	# Conecta o som de clique em TODO botão que entrar em qualquer cena
	get_tree().node_added.connect(_on_node_added)


func _make_player(stream: AudioStream, volume_db := 0.0) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = volume_db
	add_child(p)
	return p


func _on_node_added(node: Node) -> void:
	if node is BaseButton and not node.pressed.is_connected(play_click):
		node.pressed.connect(play_click)


func play_music() -> void:
	if not music_player.playing:
		music_player.play()


func stop_music() -> void:
	music_player.stop()


func play_click() -> void:
	click_player.play()


func play_collect() -> void:
	collect_player.play()


func play_laugh() -> void:
	laugh_player.play()


func play_end_jingle() -> void:
	laugh_player.stop()
	music_player.stop()
	end_player.play()
