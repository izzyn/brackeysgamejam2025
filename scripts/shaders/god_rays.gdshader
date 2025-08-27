shader_type spatial;
render_mode  blend_add, depth_draw_opaque, cull_back, diffuse_burley, shadows_disabled;

uniform float alpha : hint_range(0.0, 1.0) = 0.5;
uniform float rim_power : hint_range(0.0, 5.0) = 1.0;
uniform float rim_wiggle_speed : hint_range(0.0, 5.0) = 1.0;
uniform float rim_wiggle_amount : hint_range(0.0, 2.0) = 0.3;

uniform sampler2D texture_emission : source_color, hint_default_black,filter_linear_mipmap,repeat_enable;
uniform sampler2D gradient : source_color, hint_default_black,filter_linear_mipmap,repeat_enable;

uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 1.0) = 0.5;
uniform vec3 uv1_scale = vec3(5.0, 0.0, 0.0);
uniform vec3 uv1_offset = vec3(0.0, 1.0, 0.0);

uniform vec2 noise_scroll_speed = vec2(0.5, 0.0); // Controls direction and speed of noise travel

varying vec2 base_uv;

// rotate on 90 degrees
vec2 rotateUV(vec2 uv) {
	return vec2(1.0 * (uv.y - 0.5) + 0.5, -1.0 * (uv.y - 0.5) + 0.5);
}

void vertex() {
	base_uv = rotateUV(UV);
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec3 fallof = texture(gradient, base_uv).rgb;
	
	// Create wiggle for rim power
	float wiggled_rim_power = rim_power + sin(TIME * rim_wiggle_speed) * rim_wiggle_amount;
	float fresnel = pow(1.0 - dot(normalize(NORMAL), normalize(VIEW)), wiggled_rim_power);
	float fade = mix(1.0, -1.0, fresnel);

	ROUGHNESS = 0.0; 
	SPECULAR = 0.0;
	
	// Make the noise texture travel by scrolling UV coordinates
	vec2 scrolling_uv = UV + noise_scroll_speed * TIME;
	vec3 emission_tex = texture(texture_emission, scrolling_uv).rgb;
	EMISSION = (emission.rgb + emission_tex) * emission_energy * fallof;
	
	ALPHA = clamp(fade, 0.0, 1.0) * EMISSION.r * alpha; 
}