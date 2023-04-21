tool
extends CelestialBody

export(float) var luminocity = 5.0
var objectsInSuckArea: Array
const gradient = preload("res://Assets/Materials/StarColorGradient.tres")

func _ready():
	._ready()
	minMass = Constants.planetMassLimit
	maxMass = INF
	
func setScale():
	.setScale()
	$LightSprite.scale = Vector2.ONE * radius / 50.0
	$Light2D.scale = Vector2.ONE * radius / 50.0
	$SuckArea.scale = Vector2.ONE * radius * 3

func setMass(value: float):
	.setMass(value)
	luminocity = liniar(Constants.planetMassLimit, 0.1, Constants.starMassLimit, 10.0, mass)
	color = gradient.interpolate(liniar(Constants.planetMassLimit, 0.0, Constants.starMassLimit, 1.0, mass))
	modulate = color

func _physics_process(delta):
	if !Engine.editor_hint:
		for body in objectsInSuckArea:
			var dist = position.distance_to(body.position)
			var suck_amount = -atan(0.1*(dist - radius * 3.0))/PI + 0.5
			var sucked_mass = body.mass * suck_amount * delta * mass / body.mass * 0.2
			updateMass(mass + sucked_mass, delta)
			body.updateMass(body.mass - sucked_mass, delta)

func updateMass(newMass: float, delta: float):
	radius *= pow(newMass / mass, 0.33)
	mass = newMass
	setScale()
	checkMass()

func liniar(x1, y1, x2, y2, x):
	var a = (y2 - y1) / (x2 - x1)
	var b = y1 - a * x1
	return a * x + b

func _on_SuckArea_area_entered(area):
	if area.parent.mass < mass:
		objectsInSuckArea.append(area.parent)

func _on_SuckArea_area_exited(area):
	objectsInSuckArea.erase(area.parent)

func _on_CelestialBodyHitbox_area_entered(area):
	var otherPlanet = area.parent
	radius *= pow((mass + otherPlanet.mass) / mass, 0.33)
	velocity = (mass * velocity + otherPlanet.mass * otherPlanet.velocity) / (otherPlanet.mass + mass)
	mass += otherPlanet.mass
	setScale()
