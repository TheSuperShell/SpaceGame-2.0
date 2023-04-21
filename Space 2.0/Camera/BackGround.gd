extends Node2D

var rng = RandomNumberGenerator.new()

export(int) var amount_of_stars = 50
export(int) var max_size = 2

func _draw():
	for _i in range(amount_of_stars):
		draw_circle(Vector2(rand_range(0, 1280), rand_range(0, 720)),
		 rand_range(1, max_size),
		 Color(rng.randf_range(0.8, 1.0), rng.randf_range(0.8, 1.0), rng.randf_range(0.8, 1.0), 1))
