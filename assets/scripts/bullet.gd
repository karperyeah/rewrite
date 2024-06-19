extends Area2D
class_name Bullet

enum BulletType {
	RED = 0,
	BLUE = 1,
	GREEN = 2,
}

export var velocity : Vector2 = Vector2.ZERO
export var type = BulletType.RED
export var life_time : float = 0.6

# Who does it belong to?
enum Allegiance {
	PLAYER, # 0, Player
	ENEMY, # 1, Enemies
}

export(Allegiance) var allegiance = Allegiance.PLAYER
onready var bullet_fx_scene = preload("res://assets/scenes/fx/explosion.tscn")

# Is this belong to player, enemy, or other? Set physics layer appropriately
func set_allegiance(a):
	self.allegiance = a
	match(a):
		Allegiance.PLAYER:
			set_collision_layer_bit(3, true)
			set_collision_mask_bit(2, true)
			set_collision_mask_bit(0, true) # CHANGE FOR ARMOR-PIERCING BULLETS
		Allegiance.ENEMY:
			set_collision_layer_bit(4, true)
			set_collision_mask_bit(1, true)
		_:
			pass

func _ready():
	set_allegiance(allegiance)
	
	var life_timer = Timer.new()
	add_child(life_timer)
	life_timer.connect("timeout", self, "_on_timer_timeout")
	life_timer.wait_time = life_time
	life_timer.one_shot = true
	life_timer.start()
	
func _on_timer_timeout():
	pop()

func pop():
	var popper = bullet_fx_scene.instance()
	popper.position = self.position
	get_parent().add_child(popper)
	queue_free()

func _physics_process(delta):
	position += velocity*delta

func _process(delta):
	pass

func _on_Bullet_area_entered(area):
	pop()

func _on_Bullet_body_entered(body):
	print(body)
	pop()
