extends Node2D

var mass = 1.0
var radius = 1.0
var velocity = Vector2.ZERO
var color
var luminocity
var attached_objects = []

onready var light = $Light
onready var light_sprite = $LightSprite
onready var suck_area = $SuckArea

const gradient = preload("res://Better Celestial Bodies/Star/StarColorGradient.tres")
const influence_distance = 2.0

signal change_mass(value)
signal change_radius(value)
signal change_velocity(value)
signal change_color(value)
signal change_type(new_type)

func init(m, r, _a, _i):
	mass = m
	radius = r
	changed()

func update_type(v, delta):
	velocity = v
	suck(delta)

func eat(other_mass, _other_radius, other_velocity, _other_angular_velocity):
	update_obj(mass + other_mass, other_velocity)

func suck(delta):
	for obj in attached_objects:
		var dist = global_position.distance_to(obj.global_position)
		var suck_amount = -atan(0.1*(dist - radius * influence_distance))/PI + 0.5
		var sucked_mass = obj.mass * suck_amount * delta * mass / obj.mass * 0.1
		update_obj(mass + sucked_mass, obj.velocity)
		obj.type.update_obj(obj.mass - sucked_mass, obj.velocity, false)

func update_obj(new_mass, other_velocity, update_speed=true):
	radius *= pow(new_mass / mass, 1/3)
	if update_speed:
		velocity = (mass * velocity + abs(new_mass - mass) * other_velocity) / (new_mass)
	mass = new_mass
	emit_signal("change_mass", mass, 0.0)
	emit_signal("change_radius", radius)
	emit_signal("change_velocity", velocity)
	check_mass()
	changed()

func changed():
	color = gradient.interpolate(Usefull.liniar(Usefull.star_mass_limit, 0.0, Usefull.bh_star_limit, 1.0, mass))
	light.texture_scale = 0.6 * radius / 64
	light.color = color
	light_sprite.scale = Vector2(0.6 * radius / 64, 0.6 * radius / 64)
	luminocity = Usefull.liniar(Usefull.star_mass_limit, 0.1, Usefull.bh_star_limit, 10.0, mass)
	suck_area.scale = Vector2(radius / 64.0 * influence_distance, radius / 64.0 * influence_distance)
	emit_signal("change_color", color)
	
func check_mass():
	if mass < Usefull.star_mass_limit:
		var new_type = load("res://Better Celestial Bodies/GasGiant/GasGiant.tscn").instance()
		new_type.mass = mass
		new_type.radius = 0.8 * radius
		new_type.velocity = velocity
		new_type.global_position = global_position
		new_type.angular_velocity = rand_range(-300, 300) / 100
		new_type.planet = "Random"
		emit_signal("change_type", new_type)
	if mass >= Usefull.bh_star_limit:
		var new_type = load("res://Better Celestial Bodies/BlackHole/BlackHole.tscn").instance()
		new_type.mass = mass
		new_type.velocity = velocity
		new_type.global_position = global_position
		emit_signal("change_type", new_type)

func _on_SuckArea_area_entered(area):
	if area.host.mass < mass:
		attached_objects.append(area.host)

func _on_SuckArea_area_exited(area):
	attached_objects.erase(area.host)
