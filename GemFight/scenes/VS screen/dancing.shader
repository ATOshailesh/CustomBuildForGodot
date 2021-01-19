shader_type canvas_item;

void vertex() {
	//VERTEX.x += cos(TIME) * 5.0;
	VERTEX.y += sin(TIME) * 5.0;
}