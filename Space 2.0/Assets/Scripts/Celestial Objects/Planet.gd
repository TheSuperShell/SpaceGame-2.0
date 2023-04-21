tool
extends CelestialBody

export(String, "Earth", "Mars", "Venus", "Mercury", "Random") var planetTexture = "Random" setget setPlanetTexture

var planet_sprites = {"Earth": load("res://Assets/Textures/Celestial Objects/Planets/earth_PNG8.png"),
					  "Mars": load("res://Assets/Textures/Celestial Objects/Planets/pngwing.com.png"),
					  "Venus": load("res://Assets/Textures/Celestial Objects/Planets/Venus.png"),
					  "Mercury": load("res://Assets/Textures/Celestial Objects/Planets/Mercurt.png")}
var rng = RandomNumberGenerator.new()

func _ready():
	._ready()
	color = Color.white
	minMass = 0.0
	maxMass = Constants.planetMassLimit
	if !Engine.editor_hint:
		$CelestialBodySprite.material.set_shader_param("background_light_level", 0.05)

func UpdateRotation(delta: float):
	.UpdateRotation(delta)
	$CelestialBodySprite.material.set_shader_param("planet_position", position)
	$CelestialBodySprite.material.set_shader_param("angle", angle)

func UpdateLighting(lightTexture: Texture, number: int):
	$CelestialBodySprite.material.set_shader_param("light_sources", lightTexture)
	$CelestialBodySprite.material.set_shader_param("amount", number)

func setPlanetTexture(texture: String):
	planetTexture = texture
	if texture == "Random":
		var planets = ["Earth", "Mars", "Venus", "Mercury"]
		planets.shuffle()
		$CelestialBodySprite.texture = planet_sprites[planets[0]]
	else:
		$CelestialBodySprite.texture = planet_sprites[texture]
	setScale()
	
func _on_CelestialBodyHitbox_area_entered(area):
	var otherPlanet = area.parent
	if otherPlanet.mass == mass:
		mass += rng.randf()
	elif otherPlanet.mass > mass:
		queue_free()
		emit_signal("died", self)
	else:
		radius *= pow((mass + otherPlanet.mass) / mass, 0.33)
		velocity = (mass * velocity + otherPlanet.mass * otherPlanet.velocity) / (otherPlanet.mass + mass)
		mass += otherPlanet.mass
		setScale()
		checkMass()
