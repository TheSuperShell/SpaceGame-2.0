@tool
extends Node

@export var timeStep: float = 0.1
@export var numSteps: int = 1000
@export var reference: NodePath

var bodies: Array

class SimulatedBody:
	
	var mass: float
	var velocity: Vector2
	var pos: Vector2
	
	func _init(body: PhysicalBody):
		pos = body.position
		velocity = body.velocity
		mass = body.mass

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		bodies = get_tree().get_nodes_in_group("PhysicalBody")
		var lines = []
		var simulatedBodies = []
		var referenceBodyPos: Vector2
		var referenceBodyIndex: int
		var startPosition = Vector2.ZERO
		var l = 0
		for body in bodies:
			simulatedBodies.append(SimulatedBody.new(body))
			lines.append([])
			if reference and body == get_node(reference):
				referenceBodyIndex = l
				referenceBodyPos = body.position
				startPosition = body.position
			l += 1
		for i in range(numSteps):
			l = 0
			for body in simulatedBodies:
				body.velocity += CalculateAcceleration(body, simulatedBodies) * timeStep
				if reference and l == referenceBodyIndex:
					referenceBodyPos = body.pos
				l += 1
			for j in range(len(simulatedBodies)):
				simulatedBodies[j].pos += simulatedBodies[j].velocity * timeStep
				lines[j].append(simulatedBodies[j].pos - bodies[j].position)
				if reference:
					lines[j][i] -= referenceBodyPos - startPosition
				if reference and j == referenceBodyIndex:
					lines[j][i] = startPosition
		
		for i in range(len(bodies)):
			bodies[i].setTrajectory(lines[i])
				

func CalculateAcceleration(body: SimulatedBody, simulated: Array) -> Vector2:
	var acceleration = Vector2.ZERO
	for otherBody in simulated:
		if otherBody == body:
			continue
		var distSqrt = body.pos.distance_squared_to(otherBody.pos)
		var direction = (otherBody.pos - body.pos).normalized()
		acceleration += direction * Constants.GravitationalConstant * otherBody.mass / distSqrt
	
	return acceleration

	


