extends Node2D

const star = preload("res://Better Celestial Bodies/Star/Star.tscn")
const planet = preload("res://Better Celestial Bodies/Planet/Planet.tscn")
const gas_giant = preload("res://Better Celestial Bodies/GasGiant/GasGiant.tscn")
const bh = preload("res://Better Celestial Bodies/BlackHole/BlackHole.tscn")
var body = [planet, star, gas_giant]
var rng = RandomNumberGenerator.new()
var time_warp = 1
var time_stop: bool = false
var tails: bool = true
var image: Image = Image.new()
var texture: ImageTexture = ImageTexture.new()
var new_body_mass = 100.0
var new_body_radius = 10.0
var random = false

signal planet_chosen(planet)

enum {
	IDLE
	CREATE
	DELETE
}
var action = IDLE

func _ready():
	for planet in get_children():
		planet.connect("planet_pressed", self, "_on_planet_pressed")
	image.create(128, 2, false, Image.FORMAT_RGBAH)
	randomize()

func get_time_delta():
	return time_warp
	
func _physics_process(_delta):
	var number: int = 0
	image.lock()
	for child in get_children():
		if "Star" in child.name:
			image.set_pixel(number, 0, Color(child.global_position.x, child.global_position.y, 0, 0))
			image.set_pixel(number, 1, Color(child.type.color.r, child.type.color.g, child.type.color.b, child.type.luminocity))
			number += 1
			if number > 128:
				break
	image.unlock()
	texture.create_from_image(image)
	for child in get_children():
		if "Planet" in child.name or "Gas" in child.name:
			child.type.update_shader(texture, number)

func _input(event):
	if event.is_action_pressed("rmb") and action == CREATE:
		if random:
			create_random_body()
		else:
			var new_body
			if new_body_mass < Usefull.gas_mass_limit:
				new_body = planet.instance()
				new_body.angular_velocity = rand_range(-300, 300) / 100
				new_body.planet = "Random"
			elif new_body_mass < Usefull.star_mass_limit:
				new_body = gas_giant.instance()
				new_body.angular_velocity = rand_range(-300, 300) / 100
				new_body.planet = "Random"
			elif new_body_mass < Usefull.bh_star_limit:
				new_body = star.instance()
			else:
				new_body = bh.instance()
			new_body.state = 1 if time_stop else 0
			new_body.has_tail = tails
			new_body.mass = new_body_mass + rand_range(-10, 10)
			new_body.radius = new_body_radius
			new_body.global_position = get_local_mouse_position()
			add_child(new_body)
			new_body.connect("planet_pressed", self, "_on_planet_pressed")
	if event.is_action_pressed("trail"):
		tails = not tails
		for obj in get_children():
			obj.has_tail = tails
			if not tails:
				obj.remove_tail()

func create_random_body():
	body.shuffle()
	var new_body = body[0].instance()
	new_body.mass = rand_range(100, Usefull.gas_mass_limit*0.8) * float("Planet" in new_body.name) +\
	rand_range(Usefull.star_mass_limit, Usefull.bh_star_limit*0.8) * float("Star" in new_body.name) + \
	rand_range(Usefull.gas_mass_limit, Usefull.star_mass_limit * 0.8) * float("Gas" in new_body.name)
	new_body.radius = rand_range(4, 50) + rand_range(0, 100) * float("Star" in new_body.name)
	new_body.state = 1 if time_stop else 0
	new_body.has_tail = tails
	new_body.angular_velocity = rand_range(-300, 300) / 100
	new_body.planet = "Random"
	new_body.global_position = get_local_mouse_position()
	new_body.velocity = Vector2(rand_range(-100, 100), rand_range(-100, 100))
	add_child(new_body)
	new_body.connect("planet_pressed", self, "_on_planet_pressed")

func _on_planet_pressed(planet):
	if action == DELETE:
		planet.queue_free()
		emit_signal("planet_chosen", null)
	if action == IDLE or action == CREATE:
		emit_signal("planet_chosen", planet)

func _on_Camera_zoom_changed(value):
	for obj in get_children():
		obj.button_change(value)

func _on_Interface_toggle_time(time_stopped):
	for obj in get_children():
			obj.state = 1 if time_stopped else 0

func _on_Interface_change_time_warp(time_warpp):
	time_warp = time_warpp

func _on_Interface_toggle_action_mode(mode):
	action = mode

func _on_Interface_planet_parameters_changed(mass, radius, rand):
	new_body_mass = mass
	new_body_radius = radius
	random = rand
