extends KinematicBody2D

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var hat_sprite = get_node("Sprite/HatPosition/").get_child(0)
onready var backpack_sprite = get_node("Sprite/BackpackPosition/").get_child(0)

onready var coyote_time = $CoyoteTime

export var gravity = 640.0

export var speed = 150.0
export var acceleration = 800.0
export var deacceleration = 700.0

export var jump_velocity = 275.0

export var allow_control : bool = true

var direction : float = 0.0
var velocity : Vector2 = Vector2.ZERO
var times_jumped : int = 0

# Item data to set / also for serializing save data
enum BackpackItem {
	NOTHING,
	GUN_STANDARD, # rapid fire, limited ammo, lower damage, but higher boost?
	GUN_POWER, # single/double shot per jump, higher damage, but lower boost?
}

export var scene : String

func _gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _movement(delta: float) -> void:
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deacceleration * delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
func _jump(delta: float) -> void:
	if is_on_floor():
		times_jumped = 0
	
	if Input.is_action_just_pressed("action") and allow_control:
		if is_on_floor() or coyote_time.time_left > 0.0 or (times_jumped < 2 and times_jumped >= 1):
			times_jumped += 1
			velocity.y = -jump_velocity
			coyote_time.stop()
			
			animation_player.seek(0)
			animation_player.play("Jump")
			$JumpSound.pitch_scale = rand_range(0.7, 1.3)
			$JumpSound.play()


func _coyote_time(was_on_floor: bool) -> void:
	if was_on_floor and not is_on_floor() and velocity.y >= 0.0:
		coyote_time.start()

func _set_control_toggle(value : bool) -> void:
	allow_control = value

func _kill() -> void:
	# ADD THE OTHER STUFF, ANIMATION, ETC
	$AnimationPlayer.play("Death")
	
func _restart() -> void:
	pass

func _animation(direction: float) -> void:
	if direction:
		sprite.flip_h = direction < 0
		hat_sprite.scale.x = direction
		backpack_sprite.scale.x = direction

	if is_on_floor():
		if velocity.x == 0 and velocity.y == 0:
			animation_player.play("Idle")
		if velocity.x != 0:
			animation_player.play("Run")
	
	if not is_on_floor():
		if velocity.y > 0:
			animation_player.play("Fall")
		
	$RichTextLabel.bbcode_text = "[center]" + var2str($AnimationPlayer.current_animation) + "\n" + var2str(times_jumped) + "[/center]"


func _process(delta: float) -> void:
	if allow_control:
		direction = Input.get_axis("left", "right")
	else:
		direction = 0

func _physics_process(delta: float) -> void:
	var was_on_floor = is_on_floor()
	
	_gravity(delta)
	_movement(delta)
	_animation(direction)
	_jump(delta)
	
	_coyote_time(was_on_floor)

func _on_HurtBox_body_entered(body):
	print("Agghhh! Hurts!!! Hurtie!")
	$DeathSound.pitch_scale = rand_range(0.8, 1.2)
	$DeathSound.play()
	$Meat.play()
	_kill()
