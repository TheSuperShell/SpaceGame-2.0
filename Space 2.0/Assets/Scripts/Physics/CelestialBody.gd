@tool
class_name CelestialBody
extends PhysicalBody

@export var radius: float = 10.0: set = setRadius
@export var angularVelocity: float = 0.0
@export var nextStage = "None"  # (String, "Planet", "Star", "None")
@export var prevStage = "None" # (String, "Planet", "Star", "None")

var color: Color = Color.WHITE
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
	if Engine.is_editor_hint():
		setScale()

func setAngularVelocity(value: float) -> void:
	angularVelocity = value

func setScale() -> void:
	$CelestialBodySprite.scale = radius * 2.0 / $CelestialBodySprite.texture.get_height() * Vector2.ONE
	$CelestialBodyHitbox.scale = radius * Vector2.ONE
