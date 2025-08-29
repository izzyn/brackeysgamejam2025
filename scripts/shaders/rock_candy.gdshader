shader_type spatial;
render_mode cull_back, blend_mix, depth_draw_opaque; // Add render_mode for transparency control

//render_mode ambient_light_disabled;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform bool clamp_diffuse_to_max = false;

// EMISSION
uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 0.0;
uniform sampler2D emission_texture : source_color, filter_nearest;

// TRANSPARENCY
uniform float alpha_value : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D alpha_texture : source_color, filter_nearest;

// Triplanar Mapping Controls
uniform bool use_triplanar = false;
uniform float triplanar_scale = 1.0;
uniform float triplanar_sharpness : hint_range(0.0, 5.0) = 1.0;

uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0, 2.0) = 0.0;
uniform float steepness : hint_range(1.0, 8.0) = 1.0;

uniform bool use_attenuation = true;

uniform bool use_specular = true;
uniform float specular_strength : hint_range(0.0, 1.0) = 1.0;
uniform float specular_shininess : hint_range(0.0, 32.0) = 16.0;
uniform sampler2D specular_map : hint_default_white, filter_nearest;

uniform bool use_rim = true;
uniform float rim_width : hint_range(0.0, 16.0) = 8.0;
uniform vec4 rim_color : source_color = vec4(1.0);

uniform bool use_ramp = false;
uniform sampler2D ramp : source_color;

uniform bool use_borders = false;
uniform float border_width = 0.01;

varying vec3 world_pos;
varying vec3 world_normal;

float split_specular(float specular) {
	return step(0.5, specular);
}

// Helper function for triplanar texture sampling
vec3 triplanar_sample(sampler2D tex, float scale) {
	// Calculate blend weights based on the world normal
	vec3 blend_weights = abs(world_normal);
	blend_weights = pow(blend_weights, vec3(triplanar_sharpness));
	blend_weights = blend_weights / (blend_weights.x + blend_weights.y + blend_weights.z);

	// Sample texture from 3 axes based on world position
	vec2 uv_x = world_pos.yz * scale;
	vec2 uv_y = world_pos.xz * scale;
	vec2 uv_z = world_pos.xy * scale;
	
	vec3 tex_x = texture(tex, uv_x).rgb;
	vec3 tex_y = texture(tex, uv_y).rgb;
	vec3 tex_z = texture(tex, uv_z).rgb;

	// Blend the 3 samples
	return tex_x * blend_weights.x + tex_y * blend_weights.y + tex_z * blend_weights.z;
}

float triplanar_sample_single(sampler2D tex, float scale) {
	// Calculate blend weights based on the world normal
	vec3 blend_weights = abs(world_normal);
	blend_weights = pow(blend_weights, vec3(triplanar_sharpness));
	blend_weights = blend_weights / (blend_weights.x + blend_weights.y + blend_weights.z);

	// Sample texture from 3 axes based on world position
	vec2 uv_x = world_pos.yz * scale;
	vec2 uv_y = world_pos.xz * scale;
	vec2 uv_z = world_pos.xy * scale;
	
	float tex_x = texture(tex, uv_x).r;
	float tex_y = texture(tex, uv_y).r;
	float tex_z = texture(tex, uv_z).r;

	// Blend the 3 samples
	return tex_x * blend_weights.x + tex_y * blend_weights.y + tex_z * blend_weights.z;
}

void vertex() {
	// Transform vertex to world space
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);
}

void fragment() {
	vec3 albedo_tex;
	float specular_tex;
	vec3 emission_tex = vec3(0.0);
	float alpha_tex = 1.0;
	
	if (use_triplanar) {
		// Apply triplanar mapping to all textures
		albedo_tex = triplanar_sample(albedo_texture, triplanar_scale);
		specular_tex = triplanar_sample_single(specular_map, triplanar_scale);
		emission_tex = triplanar_sample(emission_texture, triplanar_scale);
		alpha_tex = triplanar_sample_single(alpha_texture, triplanar_scale);
	} else {
		// Default UV mapping
		albedo_tex = texture(albedo_texture, UV).rgb;
		specular_tex = texture(specular_map, UV).r;
		emission_tex = texture(emission_texture, UV).rgb;
		alpha_tex = texture(alpha_texture, UV).r;
	}
	
	// Set color and emission
	ALBEDO = albedo.rgb * albedo_tex;
	EMISSION = emission_color.rgb * emission_color.a * emission_strength * emission_tex;
	
	// Set transparency
	ALPHA = alpha_value * alpha_tex;
	
	// Ensure normal is in the correct space for lighting
	NORMAL = normalize(NORMAL);
}

void light() {
	// Use the built-in NORMAL which is already in the correct space for lighting
	vec3 normal = normalize(NORMAL);
	
	// Attenuation.
	float attenuation = 1.0;
	if (use_attenuation) {
		attenuation = ATTENUATION;
	}
	
	// Diffuse lighting.
	float NdotL = dot(normal, LIGHT);
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0 / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0 - diffuse_amount, cuts_inv), 0.0, 1.0);

	// Calculate borders.
	float border = 0.0;
	if (use_borders) {
		float corr_border_width = length(cross(normal, LIGHT)) * border_width * steepness;
		border = step(diffuse_stepped - corr_border_width, diffuse_amount)
				 - step(1.0 - corr_border_width, diffuse_amount);
	}
	
	// Apply diffuse result to different styles.
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR;
	if (use_ramp) {
		diffuse *= texture(ramp, vec2(diffuse_stepped * (1.0 - border), 0.0)).rgb;
	} else {
		diffuse *= diffuse_stepped * (1.0 - border);
	}
	
	if (clamp_diffuse_to_max) {
		// Clamp diffuse to max for multiple light sources.
		DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	} else {
		DIFFUSE_LIGHT += diffuse;
	}
	
	// Specular lighting.
	if (use_specular) {
		vec3 H = normalize(LIGHT + VIEW);
		float NdotH = dot(normal, H);
		
		float specular_value;
		if (use_triplanar) {
			specular_value = triplanar_sample_single(specular_map, triplanar_scale);
		} else {
			specular_value = texture(specular_map, UV).r;
		}
		
		float specular_amount = max(pow(NdotH, specular_shininess*specular_shininess), 0.0)
							    * specular_value
								* attenuation;
		specular_amount = split_specular(specular_amount);
		SPECULAR_LIGHT += specular_strength * specular_amount * LIGHT_COLOR;
	}
	
	// Simple rim lighting.
	if (use_rim) {
		float NdotV = dot(normal, VIEW);
		float rim_light = pow(1.0 - NdotV, rim_width);
		SPECULAR_LIGHT += rim_light * rim_color.rgb * rim_color.a * LIGHT_COLOR / PI;
	}
}