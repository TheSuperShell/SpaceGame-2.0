extends Node

var G: float = Constants.GravitationalConstant
var PhysicalBodies: Array

func _ready():
	PhysicalBodies = get_tree().get_nodes_in_group("PhysicalBody")
	for body in PhysicalBodies:
		body.connect("died", Callable(self, "deletObject"))

func _physics_process(delta: float) -> void:
	for body in PhysicalBodies:
		body.UpdateVelocity(delta, CalculateAcceleration(body, body))
		
	for body in PhysicalBodies:
		body.UpdatePosition(delta)
		body.UpdateRotation(delta)

func CalculateAcceleration(body: CelestialBody, ignore: CelestialBody = null) -> Vector2:
	var acceleration = Vector2.ZERO
	for otherBody in PhysicalBodies:
		if otherBody == ignore:
			continue
		var distSqrt = otherBody.position.distance_squared_to(body.position)
		var direction = (otherBody.position - body.position).normalized()
		if body.position.distance_to(otherBody.position) < otherBody.radius:
			acceleration += G * otherBody.mass * (otherBody.position - body.position) / pow(otherBody.radius, 3)
		else:
			acceleration += direction * G * otherBody.mass / distSqrt
	
	return acceleration

func deletObject(obj):
	PhysicalBodies.erase(obj)
	obj.disconnect("died", Callable(self, "deletObject"))

func _on_Spawner_addBody(body):
	PhysicalBodies.append(body)
	body.connect("died", Callable(self, "deletObject"))
