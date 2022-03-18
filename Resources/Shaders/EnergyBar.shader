shader_type canvas_item;

uniform float offset : hint_range(0.0, 1.0) = 0.0;
void vertex() {
	VERTEX.y += sin(TIME * 50.0) * (10.0 * offset);
	VERTEX.x += cos(TIME * 40.0) * (5.0 * offset);
}