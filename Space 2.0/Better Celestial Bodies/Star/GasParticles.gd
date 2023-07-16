@tool
extends GPUParticles2D

@export var destination: Vector2 = Vector2.ZERO: set = set_destination

func set_destination(new_dest):
	destination = new_dest
	process_material.direction = Vector3(new_dest.x, new_dest.y, 0.0)
	$Marker2D.position = new_dest
