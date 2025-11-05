shader_type spatial;

render_mode blend_mix,
	cull_disabled,
	shadows_disabled,
	specular_disabled,
	vertex_lighting;
stencil_mode write,
	compare_always,
	1; // WRITE '1' to the stencil buffer always

uniform bool affine_mapping = false;
uniform sampler2D albedo : source_color, filter_nearest;
uniform float alpha_scissor : hint_range(0, 1) = 0.5;
uniform float jitter: hint_range(0, 1) = 0.25;
uniform ivec2 resolution = ivec2(320, 240);

vec4 snap_to_position(vec4 base_position)
{
	if (jitter == 0.0)
	{
		return base_position;
	}

	vec4 snapped_position = base_position;
	snapped_position.xyz = base_position.xyz / base_position.w;

	vec2 snap_resulotion = floor(vec2(resolution) * (1.0 - jitter));
	snapped_position.x = floor(snap_resulotion.x * snapped_position.x) / snap_resulotion.x;
	snapped_position.y = floor(snap_resulotion.y * snapped_position.y) / snap_resulotion.y;

	snapped_position.xyz *= base_position.w;
	return snapped_position;
}

void vertex()
{
	vec4 snapped_position = snap_to_position(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	if (affine_mapping)
	{
		POSITION = snapped_position;
		POSITION /= abs(POSITION.w);
	}
	else
	{
		POSITION = snapped_position;
	}
}

void fragment()
{
	vec4 color_base = COLOR;
	vec4 texture_color = texture(albedo, UV);

	ALBEDO = (color_base * texture_color).rgb;
	ALPHA = texture_color.a * color_base.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}

//void fragment()
//{
	//// Set alpha to 0.0 to make the object invisible, 
    //// but the stencil buffer still gets written.
	//ALBEDO = vec3(0.0);
	//ALPHA = 0.0;
//}