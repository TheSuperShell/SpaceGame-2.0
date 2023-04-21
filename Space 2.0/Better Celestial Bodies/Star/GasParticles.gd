tool
extends Particles2D

export(Vector2) var destination = Vector2.ZERO setget set_destination

func set_destination(new_dest):
	destination = new_dest
	process_material.direction = Vector3(new_dest.x, new_dest.y, 0.0)
	$Position2D.position = new_dest
