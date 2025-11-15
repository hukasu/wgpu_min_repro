//! Show passing textures as parameters to shader functions

use bevy::{
    DefaultPlugins,
    app::{App, Startup},
    asset::{Asset, AssetServer, Handle},
    camera::Camera3d,
    color::Color,
    ecs::system::{Commands, Res},
    image::Image,
    light::DirectionalLight,
    math::{
        Vec2, Vec3,
        primitives::{Cuboid, Plane3d},
    },
    mesh::Mesh3d,
    pbr::{Material, MaterialPlugin, MeshMaterial3d, StandardMaterial},
    reflect::Reflect,
    render::{alpha::AlphaMode, render_resource::AsBindGroup},
    transform::components::Transform,
};

fn main() {
    let mut app = App::new();

    app.add_plugins(DefaultPlugins);
    app.add_plugins(MaterialPlugin::<MyTexture>::default());

    app.add_systems(Startup, setup);

    app.run();
}

fn setup(mut commands: Commands, asset_server: Res<AssetServer>) {
    commands.spawn((
        Camera3d::default(),
        Transform::from_translation(Vec3::new(0., 5., 5.)).looking_at(Vec3::ZERO, Vec3::Y),
    ));
    commands.spawn((
        DirectionalLight {
            shadows_enabled: true,
            ..Default::default()
        },
        Transform::from_translation(Vec3::new(-5., 5., 5.)).looking_at(Vec3::ZERO, Vec3::Y),
    ));

    commands.spawn((
        Mesh3d(asset_server.add(Plane3d::new(Vec3::Y, Vec2::splat(5.)).into())),
        MeshMaterial3d(asset_server.add(StandardMaterial::from_color(Color::WHITE))),
    ));
    commands.spawn((
        Mesh3d(asset_server.add(Cuboid::new(2., 2., 2.).into())),
        MeshMaterial3d(asset_server.add(MyTexture {
            image: asset_server.load("bevy_bird_dark.png"),
        })),
        Transform::from_translation(Vec3::new(0., 1., 0.)),
    ));
}

#[derive(Debug, Clone, Reflect, Asset, AsBindGroup)]
// #[bindless(index_table(range(0..2)))]
struct MyTexture {
    #[texture(0)]
    #[sampler(1)]
    image: Handle<Image>,
}

impl Material for MyTexture {
    fn alpha_mode(&self) -> AlphaMode {
        AlphaMode::Opaque
    }

    fn fragment_shader() -> bevy::shader::ShaderRef {
        "shaders/texture_as_parameter.wgsl".into()
    }
}
