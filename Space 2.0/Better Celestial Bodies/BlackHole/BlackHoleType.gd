extends Node2D

onready var sprite = $Body
onready var aura = $Aura
onready var suck_area = $SuckArea

var mass = 1.0
var radius = 1.0
var velocity = Vector2.ZERO
var attached_objects = []

signal change_mass(value)
signal change_radius(value)
signal change_velocity(value)
signal switch_tail()

const influence_distance = 12.0

func init(m, _r, _a, _i):
	update_obj(m, Vector2.ZERO, false)
	emit_signal("switch_tail")

func update_type(v, d):
	velocity = v
	suck(d)

func update_obj(new_mass, other_velocity, change_velocity=true):
	radius = 0.00000004 * new_mass
	emit_signal("change_radius", radius)
	sprite.scale = Vector2(radius / 64, radius / 64)
	aura.scale = Vector2(radius * 0.1, radius * 0.1)
	suck_area.scale = Vector2(radius / 64.0 * influence_distance, radius / 64.0 * influence_distance)
	if change_velocity:
		velocity = (mass * velocity + (new_mass - mass) * other_velocity) / new_mass
		emit_signal("change_velocity", velocity)
	mass = new_mass
	emit_signal("change_mass", mass, 0.0)

func eat(other_mass, _other_radius, other_velocity, _other_angular):
	update_obj(mass + other_mass, other_velocity)

func suck(delta):
	for obj in attached_objects:
		var dist = global_position.distance_to(obj.global_position)
		var suck_amount = exp(-pow(dist, 2)/(2 * pow(radius * influence_distance/3.0,2)))
		var sucked_mass = obj.mass * suck_amount * delta * 20.0
		update_obj(mass + sucked_mass, obj.velocity)
		obj.type.update_obj(obj.mass - sucked_mass, obj.velocity, false)

func _on_SuckArea_area_entered(area):
	attached_objects.append(area.host)

func _on_SuckArea_area_exited(area):
	attached_objects.erase(area.host)
