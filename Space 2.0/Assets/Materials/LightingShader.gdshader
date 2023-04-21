shader_type canvas_item;

const float pi = 3.14;

uniform float background_light_level = 0.05;
uniform sampler2D light_sources;
uniform int amount = 0;
uniform vec2 planet_position = vec2(0.0, 0.0);
uniform float angle;
uniform float stipness = 50.0;

void fragment(){
	vec2 rotate = vec2((UV.x - 0.5) * cos(angle) - (UV.y - 0.5) * sin(angle), (UV.x - 0.5) * sin(angle) + (UV.y - 0.5) * cos(angle)) + vec2(0.5, 0.5);
	vec4 previous_color = texture(TEXTURE, rotate);
	vec3 w_b = vec3(0.0, 0.0, 0.0);
	for (int i = 0; i < amount; i++) {
		vec4 texel = texelFetch(light_sources, ivec2(i, 0), 0);
		vec4 star_color = texelFetch(light_sources, ivec2(i, 1), 0);
		vec2 star_position = texel.rg;
		vec2 planet_to_star = star_position - planet_position;
		float light_amount = clamp(400000.0 * star_color.a / pow(length(planet_to_star), 2), 0.0, 1.0);
		float dot_product = dot(UV - vec2(0.5, 0.5), normalize(planet_to_star));
		float koef = (atan(dot_product * stipness)/pi + 0.5) * light_amount / 1.1;
		w_b = w_b + vec3(koef * star_color.r, koef * star_color.g, koef * star_color.b);
	}
	w_b = w_b + vec3(background_light_level, background_light_level, background_light_level);
	w_b = clamp(w_b, 0.0, 1.0);
	vec4 new_color = vec4(w_b.x * previous_color.r, w_b.y * previous_color.g, w_b.z * previous_color.b, previous_color.a);
	COLOR = new_color;
}