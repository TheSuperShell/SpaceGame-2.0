extends Node2D

var rng = RandomNumberGenerator.new()

@export var amount_of_stars: int = 50
@export var max_size: int = 2

func _draw():
	for _i in range(amount_of_stars):
		draw_circle(Vector2(randf_range(0, 1280), randf_range(0, 720)),
		 randf_range(1, max_size),
		 Color(rng.randf_range(0.8, 1.0), rng.randf_range(0.8, 1.0), rng.randf_range(0.8, 1.0), 1))
