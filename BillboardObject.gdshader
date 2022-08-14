// NOTE: Shader automatically converted from Godot Engine 3.5.stable's SpatialMaterial.

shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color = vec4(1, 1, 1, 1);
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular = 0.5;
uniform float metallic = 0;
uniform float alpha_scissor_threshold = 0.98;
uniform float roughness : hint_range(0,1) = 1;
uniform float point_size : hint_range(0,128) = 1;
uniform vec3 uv1_scale = vec3(1, 1, 1);
uniform vec3 uv1_offset = vec3 (0, 0, 0);
uniform vec3 uv2_scale = vec3(1, 1, 1);
uniform vec3 uv2_offset = vec3(0, 0, 0);

uniform mat4 pivot_transform;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * inverse(pivot_transform) * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), CAMERA_MATRIX[2].xyz)),0.0), vec4(0.0, 1.0, 0.0, 0.0),vec4(normalize(cross(CAMERA_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))),0.0),WORLD_MATRIX[3]) * pivot_transform;	
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = albedo.a * albedo_tex.a;
	ALPHA_SCISSOR=alpha_scissor_threshold;
}
