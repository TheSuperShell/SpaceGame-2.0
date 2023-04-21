tool
class_name CelestialBody
extends PhysicalBody

export var radius: float = 10.0 setget setRadius
export var angularVelocity: float = 0.0
export(String, "Planet", "Star", "None") var nextStage = "None" 
export(String, "Planet", "Star", "None") var prevStage = "None"

var color: Color = Color.white
var angle: float = 0.0
var minMass: float
var maxMass: float

signal died(body)
signal changeType(body, newType)

func _ready():
	setScale()
	modulate = color
	$Trajectory.points = []

func UpdateRotation(delta: float):
	angle += angularVelocity * delta
	if abs(angle) >= 2*PI:
		angle -= 2*PI * sign(angle)

func checkMass() -> void:
	if mass > maxMass:
		queue_free()
		emit_signal("died", self)
		emit_signal("changeType", self, nextStage)
	elif mass <= minMass:
		queue_free()
		emit_signal("died", self)
		emit_signal("changeType", self, prevStage)

func setTrajectory(trajectory: Array):
	$Trajectory.points = trajectory
	$Trajectory.default_color = color

func setRadius(value: float) -> void:
	radius = value
	if Engine.editor_hint:
		setScale()

func setAngularVelocity(value: float) -> void:
	angularVelocity = value

func setScale() -> void:
	$CelestialBodySprite.scale = radius * 2.0 / $CelestialBodySprite.texture.get_height() * Vector2.ONE
	$CelestialBodyHitbox.scale = radius * Vector2.ONE
