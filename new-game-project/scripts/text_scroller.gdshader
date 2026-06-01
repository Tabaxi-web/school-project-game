shader_type canvas_item;
uniform vec2 direction = vec2(0.0, 1.0);
uniform float speed = 1.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 scrolled_uv = UV + direction * speed * TIME;
	COLOR = texture(TEXTURE, scrolled_uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
