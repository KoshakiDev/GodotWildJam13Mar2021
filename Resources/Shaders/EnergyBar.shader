shader_type canvas_item;

uniform float offset : hint_range(0f, 1f) = 0.0;
void vertex() {
	VERTEX.y += sin(TIME * 50f) * (10f * offset);
	VERTEX.x += cos(TIME * 40f) * (5f * offset);
}