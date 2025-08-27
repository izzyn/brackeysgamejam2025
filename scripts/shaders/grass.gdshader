
shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;
uniform float windStrength = 0.2;
uniform float windSpeed = 2.0;
uniform vec2 windDirection = vec2(1.0, 0.0);
uniform float windRandomness = 0.3;

// New uniforms for cloud shadows
uniform float cloudSpeed = 0.1; // Speed of cloud movement
uniform vec2 cloudDirection = vec2(1.0, 0.5); // Direction of cloud movement
uniform float cloudShadowStrength = 0.3; // How much the shadows affect grass color

varying vec3 worldPos;

void vertex() {
	worldPos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vec3 noiseSample1 = texture(noise, worldPos.xz / noiseScale).rgb;
	vec3 noiseSample2 = texture(noise, worldPos.xz / (noiseScale * 0.7) + vec2(0.2, 0.8)).rgb;

	float windTime = TIME * windSpeed;
	float windWave = sin(windTime + worldPos.x * 0.5 + worldPos.z * 0.3 + noiseSample1.r * 2.0) * 0.5 + 0.5;
	float windJitter = (noiseSample2.g * 2.0 - 1.0) * windRandomness;

	float windAmount = (windWave + windJitter) * windStrength * noiseSample1.b;

	vec2 randomDirection = normalize(windDirection + (noiseSample2.rg - 0.5) * windRandomness);
	VERTEX.x += windAmount * randomDirection.x;
	VERTEX.z += windAmount * randomDirection.y;

	float bendAmount = windAmount * (0.5 + noiseSample1.g * 0.5);
	NORMAL = normalize(NORMAL + vec3(
		randomDirection.x * bendAmount * 0.5,
		0.0,
		randomDirection.y * bendAmount * 0.5
	));
}

void fragment() {
	// Calculate cloud shadow position (moving over time)
	vec2 cloudUV = worldPos.xz / noiseScale + cloudDirection * TIME * cloudSpeed;
	vec3 cloudNoise = texture(noise, cloudUV).rgb;

	// Original grass color
	vec3 baseColor = mix(color, color2, UV.y);

	// Apply cloud shadow effect
	float shadowFactor = mix(1.0 - cloudShadowStrength, 1.0, cloudNoise.r);
	ALBEDO = baseColor * shadowFactor;

	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}