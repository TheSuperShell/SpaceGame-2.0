extends Node

var rng = RandomNumberGenerator.new()
var celestialObjects = {"Planet": preload("res://Assets/Prehabs/Celestial Objects/Planet.tscn"),
						"Star": preload("res://Assets/Prehabs/Celestial Objects/Star.tscn")}

signal addBody(body)

func _ready():
	for body in get_tree().get_nodes_in_group("PhysicalBody"):
		body.connect("changeType", Callable(self, "spawn"))

func _input(event):
	if event.is_action_pressed("rmb"):
		randomSpawn(get_viewport().get_mouse_position())

func spawn(body, newType):
	var newPlanet = celestialObjects[newType].instantiate()
	newPlanet.mass = body.mass
	newPlanet.angle = body.angle
	newPlanet.angularVelocity = body.angularVelocity
	newPlanet.initVelocity = body.velocity
	get_parent().add_child(newPlanet)
	newPlanet.position = body.position
	newPlanet.connect("changeType", Callable(self, "spawn"))
	emit_signal("addBody", newPlanet)

func randomSpawn(pos: Vector2):
	var objects = ["Star", "Planet"]
	objects.shuffle()
	var newObj = celestialObjects[objects[0]].instantiate()
	newObj.mass = rng.randf_range(1.0, 100000000.0)
	newObj.radius = rng.randf_range(5.0, 120.0)
	newObj.angularVelocity = rng.randf_range(-PI, PI)
	newObj.initVelocity = Vector2(rng.randf_range(-40.0, 40.0), rng.randf_range(-40.0, 40.0))
	get_parent().add_child(newObj)
	newObj.position = pos
	newObj.connect("changeType", Callable(self, "spawn"))
	emit_signal("addBody", newObj)
	
