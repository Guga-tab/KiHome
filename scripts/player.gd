extends CharacterBody2D

const SPEED = 100.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		_atualizar_animacao(direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
	
func _atualizar_animacao(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("right")
		else:
			anim.play("left")
	else:
		if direction.y > 0:
			anim.play("down")
		else:
			anim.play("up")
