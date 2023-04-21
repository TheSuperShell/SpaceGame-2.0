class_name PhysicalBody
extends Node2D

export var mass: float = 1.0 setget setMass
export var initVelocity: Vector2 = Vector2.ZERO setget setInitVelocity

var velocity: Vector2

func _ready():
	velocity = initVelocity

func UpdateVelocity(delta: float, acceleration: Vector2) -> void:
	velocity += acceleration * delta

func UpdatePosition(delta: float) -> void:
	position += velocity * delta

func setInitVelocity(vec: Vector2):
	initVelocity = vec
	velocity = vec

func setMass(value: float):
	mass = value
