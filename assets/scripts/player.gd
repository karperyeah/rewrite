extends KinematicBody2D

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var hat_sprite = get_node("Sprite/HatPosition/").get_child(0)
onready var backpack_sprite = get_node("Sprite/BackpackPosition/").get_child(0)
onready var camera_focus : Position2D = $CameraFocus

onready var coyote_time = $CoyoteTime

export var gravity = 640.0

export var speed = 150.0
export var acceleration = 800.0
export var deacceleration = 700.0

export var jump_velocity = 275.0

export var maximum_jumps : int = 2
export var allow_control : bool = true

var direction : float = 0.0
var velocity : Vector2 = Vector2.ZERO
var times_jumped : int = 0
var face : int = 1 # digital face direction of player

# Item data to set / also for serializing save data
enum BackpackItem {
	NOTHING,
	GUN_STANDARD, # rapid fire, limited ammo, lower damage, but higher boost?
	GUN_POWER, # single/double shot per jump, higher damage, but lower boost?
}

# Bullet scene
onready var bullet_scene = preload("res://assets/scenes/actors/projectiles/bullet.tscn")

export var scene : String

func _gravity(delta: float) -> void:
	var wall_climb_slowdown_factor = 0.5
	
	if not is_on_floor():
		if is_on_wall() and can_wall_climb() and velocity.y < 0:
			velocity.y += gravity * delta * wall_climb_slowdown_factor
		else:
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
		if is_on_floor() or coyote_time.time_left > 0.0 or (times_jumped < maximum_jumps and times_jumped >= 1):
			times_jumped += 1
			
			animation_player.seek(0)
			animation_player.play("Jump")
			$JumpSound.pitch_scale = rand_range(0.7, 1.3)
			$JumpSound.play()
			
			# temporary double jump bullet 
			if(times_jumped > 1):
				var b1 = bullet_scene.instance()
				b1.position = self.position + Vector2(0, 8)
				b1.velocity = Vector2(0, 400)
				b1.set_allegiance(Bullet.Allegiance.PLAYER)	
				get_parent().add_child(b1)   
				$Meat.play()
				
				velocity.y = -jump_velocity
				coyote_time.stop()
			else:
				velocity.y = -jump_velocity
				coyote_time.stop()


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
	if direction > 0:
		face = 1
	elif direction < 0:
		face = -1
	
	if face:
		sprite.flip_h = face < 0
		hat_sprite.scale.x = face
		backpack_sprite.scale.x = face

	if is_on_floor():
		if velocity.x == 0 and velocity.y == 0:
			animation_player.play("Idle")
		if velocity.x != 0:
			animation_player.play("Run")
	if not is_on_floor():
		if is_on_wall() and can_wall_climb():
			animation_player.play("Slide")
		else:
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

func is_on_wall() -> bool:
	return ($LeftWallRay.is_colliding() or $RightWallRay.is_colliding())

func can_wall_climb() -> bool:
	return !$WallClimbThreshold.is_colliding()

func _on_HurtBox_body_entered(body):
	print("Agghhh! Hurts!!! Hurtie!")
	$DeathSound.pitch_scale = rand_range(0.8, 1.2)
	$DeathSound.play()
	$Meat.play()
	_kill()
