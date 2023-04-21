extends Node

var image: Image = Image.new()
var texture: ImageTexture = ImageTexture.new()

func _ready():
	image.create(128, 2, false, Image.FORMAT_RGBAH)

func _process(delta):
	var number: int = 0
	var lightScources = get_tree().get_nodes_in_group("LightSource")
	var solids = get_tree().get_nodes_in_group("SolidBody")
	image.lock()
	for lightSource in lightScources:
		image.set_pixel(number, 0, Color(lightSource.position.x, lightSource.position.y, 0, 0))
		image.set_pixel(number, 1, Color(lightSource.color.r, lightSource.color.g, lightSource.color.b, lightSource.luminocity))
		number += 1
		if number > 128:
			break
	image.unlock()
	texture.create_from_image(image)
	for solid in solids:
		solid.UpdateLighting(texture, number)
