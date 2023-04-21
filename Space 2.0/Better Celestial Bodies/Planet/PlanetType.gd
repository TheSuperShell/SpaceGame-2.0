extends Node2D

onready var sprite = $Body

var mass = 1.0
var radius = 1.0
var velocity = Vector2.ZERO
var angular_velocity = 0.0
var angle = 0.0

signal change_mass(value, angular)
signal change_radius(value)
signal change_velocity(value)
signal change_type(new_type)

var planet_sprites = {"Earth": load("res://Better Celestial Bodies/Planet/Planets/earth_PNG8.png"),
					  "Mars": load("res://Better Celestial Bodies/Planet/Planets/pngwing.com.png"),
					  "Venus": load("res://Better Celestial Bodies/Planet/Planets/Venus.png"),
					  "Mercury": load("res://Better Celestial Bodies/Planet/Planets/Mercurt.png")}

func init(m, r, a, p):
	mass = m
	radius = r
	angular_velocity = a
	if p in planet_sprites:
		sprite.texture = planet_sprites[p]
	else:
		random_texture()
	sprite.scale = Vector2(r / sprite.texture.get_width(), r / sprite.texture.get_width())
	
func random_texture():
	var new_texture = ["Earth", "Mars", "Venus", "Mercury"]
	new_texture.shuffle()
	sprite.texture = planet_sprites[new_texture[0]]

func update_shader(texture, number):
	sprite.material.set_shader_param("amount", number)
	sprite.material.set_shader_param("light_sources", texture)
	sprite.material.set_shader_param("planet_position", global_position)
	sprite.material.set_shader_param("angle", angle)

func update_type(v, d):
	velocity = v
	angle += angular_velocity * d

func eat(other_mass, other_radius, other_velocity, other_angular):
	var prev_rad = radius
	radius *= pow((mass + other_mass) / mass, 1/3)
	angular_velocity = (angular_velocity * mass * pow(prev_rad, 2) + other_angular * other_mass * pow(other_radius, 2)) / ((other_mass + mass) * pow(radius, 2))
	velocity = (mass * velocity + other_mass * other_velocity) / (other_mass + mass)
	mass += other_mass
	emit_signal("change_mass", mass, angular_velocity)
	emit_signal("change_radius", radius)
	emit_signal("change_velocity", velocity)
	sprite.scale = Vector2(radius / sprite.texture.get_width(), radius / sprite.texture.get_width())
	check_mass()

func check_mass():
	if mass >= Usefull.gas_mass_limit:
		var new_type = load("res://Better Celestial Bodies/GasGiant/GasGiant.tscn").instance()
		new_type.mass = mass
		new_type.radius = radius
		new_type.velocity = velocity
		new_type.global_position = global_position
		new_type.angular_velocity = angular_velocity
		emit_signal("change_type", new_type)
