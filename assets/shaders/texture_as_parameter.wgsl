#import bevy_pbr::{
    forward_io::{VertexOutput, FragmentOutput},
}

#ifdef BINDLESS

#import bevy_pbr::{
    mesh_bindings::mesh,
}

struct MyTextureBindings {
    my_texture: u32,
    my_sampler: u32,
}

@group(#{MATERIAL_BIND_GROUP}) @binding(0) var<storage> my_texture_bindings: array<MyTextureBindings>;

#import bevy_render::bindless::{bindless_samplers_filtering, bindless_textures_2d}

#else

@group(#{MATERIAL_BIND_GROUP}) @binding(0) var my_texture: texture_2d<f32>;
@group(#{MATERIAL_BIND_GROUP}) @binding(1) var my_sampler: sampler;

#endif // BINDLESS

fn sample_a_texture(
    a_texture: texture_2d<f32>,
    a_sampler: sampler,
    uv: vec2<f32>
) -> vec4<f32> {
    return textureSample(a_texture, a_sampler, uv);
}

@fragment
fn fragment(in: VertexOutput) -> FragmentOutput {
    var out: FragmentOutput;

#ifdef BINDLESS
    let slot = mesh[in.instance_index].material_and_lightmap_bind_group_slot & 0xffffu;
    let bindings = my_texture_bindings[slot];
    let base_color: vec4<f32> = vec4<f32>(sample_a_texture(
        bindless_textures_2d[bindings.my_texture],
        bindless_samplers_filtering[bindings.my_sampler],
        in.uv
    ));
#else   // BINDLESS
    let base_color = sample_a_texture(my_texture, my_sampler, in.uv);
#endif // BINDLESS

    out.color = base_color;
    // When in BINDLESS, if the below if commented, the app crashes
    // out.color = vec4<f32>(1.);

    return out;
}
