extends Node2D

@export var radius: float = 10: set = set_radius
@export var mass: float = 100: set = set_mass
@export var velocity = Vector2.ZERO
@export var has_tail: bool = true
@export var angular_velocity: float = 0.0
@export var planet = "Earth" # (String, "Earth", "Mars", "Venus", "Mercury", "Jupiter", "Neptune", "Uranus", "Saturn", "Random")
var planet_stats_is_seen = false

@onready var collision = $CollisionArea
@onready var tail = $Tail
@onready var type = $Type
@onready var button = $ButtonNode
@onready var circle = $Circle
@onready var camera_control = $RemoteTransform2D

signal planet_pressed(planet)

enum {
	PLAYING
	PAUSE
}
var state = PLAYING
var new_object_state = null

func button_change(value):
	value = clamp(value * 0.7, radius * 1.3 / 64.0, INF)
	button.scale = Vector2(value, value)
	circle.scale = Vector2(value, value)

func set_mass(value):
	mass = value
	$CollisionArea.mass = value

func set_radius(value):
	radius = value
	$CollisionArea.radius = radius
	$CollisionArea.scale = Vector2(value / 64.0, value / 64.0)
	
func _ready():
	self.mass = mass
	self.radius = radius
	collision.angular_velocity = angular_velocity
	type.init(mass, radius, angular_velocity, planet)

func update_velocity(delta, list):
	for body in list.get_children():
		if body != self:
			var r = global_position.direction_to(body.global_position)
			var d = global_position.distance_to(body.global_position)
			if global_position.distance_to(body.global_position) <= body.radius:
				velocity += Usefull.G * body.mass / pow(body.radius, 3) * r * d * delta * list.get_time_delta()
			else:
				velocity += Usefull.G * body.mass / pow(d, 2) * r * delta * list.get_time_delta()

func destroy():
	var pos = global_position
	var size = Usefull.map_size
	if pos.y < size[0] or pos.y > size[1] or pos.x > size[3] or pos.x < size[2]:
		queue_free()

func new_state():
	if new_object_state:
		get_parent().add_child(new_object_state)
		new_object_state.connect("planet_pressed", Callable(get_parent(), "_on_planet_pressed"))
		queue_free()
		new_object_state = null
		
func playing(delta):
	var list = get_parent()
	collision.velocity = velocity
	update_velocity(delta, list)
	global_position += velocity * delta * list.get_time_delta()
	type.update_type(velocity, delta * list.get_time_delta())
	if has_tail:
		tail.global_position = Vector2.ZERO
		tail.add_point(global_position)
		if tail.get_point_count() > 300:
			tail.remove_point(0)
	destroy()
	new_state()

func _physics_process(delta):
	match state:
		PLAYING:
			playing(delta)
		PAUSE:
			pass

func remove_tail():
	tail.clear_points()

func _change_mass(value, angular):
	self.mass = value
	collision.angular_velocity = angular

func _change_radius(value):
	self.radius = value

func _change_velocity(value):
	self.velocity = value

func _on_CollisionArea_area_entered(area):
	if area.mass > mass:
		queue_free()
	elif area.mass < mass:
		type.eat(area.mass, area.radius, area.velocity, area.angular_velocity)

func _change_type(new_type):
	new_object_state = new_type

func _change_color(value):
	tail.gradient.colors[1] = value

func _on_Type_switch_tail():
	tail.visible = false

func _on_Button_mouse_entered():
	$Circle.visible = true

func _on_Button_mouse_exited():
	$Circle.visible = false

func _on_Button_pressed():
	emit_signal("planet_pressed", self)
