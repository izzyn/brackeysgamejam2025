shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform float fade_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 white_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
    ALBEDO = white_color;
    ALPHA = fade_amount;
}