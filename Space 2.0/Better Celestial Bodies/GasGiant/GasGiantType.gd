extends Node2D

var mass = 1.0
var radius = 1.0
var velocity = Vector2.ZERO
var angular_velocity = 0.0
var angle = 0.0
var color

@onready var body = $Body

signal change_mass(value)
signal change_radius(value)
signal change_velocity(value)
signal change_color(value)
signal change_type(new_type)

const influence_distance = 1.3
var texture = {"Jupiter": preload("res://Better Celestial Bodies/GasGiant/GasGiants/Jupiter.png"),
			   "Neptune": preload("res://Better Celestial Bodies/GasGiant/GasGiants/kisspng-neptune-outer-planets-uranus-solar-system-planeta-5b0e6046477516.3797402815276688062927.png"),
			   "Uranus": preload("res://Better Celestial Bodies/GasGiant/GasGiants/3D_Uranus.png"),
			   "Saturn": preload("res://Better Celestial Bodies/GasGiant/GasGiants/Saturn.png")}

func init(m, r, a, i):
	mass = m
	radius = r
	angular_velocity = a
	if i in texture:
		body.texture = texture[i]
	elif i == "Random":
		random_texture()
	changed()
	
func random_texture():
	var new_texture = ["Jupiter", "Neptune", "Uranus", "Saturn"]
	new_texture.shuffle()
	body.texture = texture[new_texture[0]]

func update_type(v, delta):
	velocity = v
	angle += angular_velocity * delta

func update_shader(textur, number):
	body.material.set_shader_parameter("amount", number)
	body.material.set_shader_parameter("light_sources", textur)
	body.material.set_shader_parameter("planet_position", global_position)
	body.material.set_shader_parameter("angle", angle)

func eat(other_mass, other_radius, other_velocity, other_angular):
	var future_radius = radius * pow((mass + other_mass) / mass, 1/3)
	angular_velocity = (angular_velocity * mass * pow(radius, 2) + other_angular * other_mass * pow(other_radius, 2)) / ((other_mass + mass) * pow(future_radius, 2))
	update_obj(mass + other_mass, other_velocity)
	

func update_obj(new_mass, other_velocity, update_speed=true):
	radius *= pow(new_mass / mass, 1/3)
	if update_speed:
		velocity = (mass * velocity + abs(new_mass - mass) * other_velocity) / (new_mass)
	mass = new_mass
	emit_signal("change_mass", mass, angular_velocity)
	emit_signal("change_radius", radius)
	emit_signal("change_velocity", velocity)
	check_mass()
	changed()

func changed():
	body.scale = Vector2(radius / body.texture.get_width(), radius / body.texture.get_width())
	emit_signal("change_color", color)
	
func check_mass():
	if mass < Usefull.gas_mass_limit:
		var new_type = load("res://Better Celestial Bodies/Planet/Planet.tscn").instantiate()
		new_type.mass = mass
		new_type.radius = 0.8 * radius
		new_type.velocity = velocity
		new_type.global_position = global_position
		new_type.angular_velocity = angular_velocity
		emit_signal("change_type", new_type)
	if mass >= Usefull.star_mass_limit:
		var new_type = load("res://Better Celestial Bodies/Star/Star.tscn").instantiate()
		new_type.mass = mass
		new_type.velocity = velocity
		new_type.global_position = global_position
		emit_signal("change_type", new_type)
