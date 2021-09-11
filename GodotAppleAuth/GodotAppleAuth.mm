//
//  GodotAppleAuth.m
//  GodotAppleAuth
//
//  Created by Oleksandr Kurtsev on 11/09/2021.
//

#import "GodotAppleAuth.h"
#import "AppleProvider.h"

#pragma mark - Initialization -

GodotAppleAuth *plugin;

void init_godot_apple_auth() {
    plugin = memnew(GodotAppleAuth);
    Engine::get_singleton()->add_singleton(Engine::Singleton(PLUGIN_NAME, plugin));
}

void deinit_godot_apple_auth() {
    if (plugin) {
       memdelete(plugin);
   }
}

void GodotAppleAuth::_bind_methods() {
    ClassDB::bind_method(D_METHOD("sign_in"), &GodotAppleAuth::signIn);
    ClassDB::bind_method(D_METHOD("sign_out"), &GodotAppleAuth::signOut);
    ClassDB::bind_method(D_METHOD("credential"), &GodotAppleAuth::credential);
    
    ADD_SIGNAL(MethodInfo(String(SIGNAL_CREDENTIAL), PropertyInfo(Variant::DICTIONARY, "result")));
    ADD_SIGNAL(MethodInfo(String(SIGNAL_AUTHORIZATION), PropertyInfo(Variant::DICTIONARY, "result")));
}

#pragma mark - Implementation -

void GodotAppleAuth::signIn() {
    [AppleProvider.shared signIn];
}

void GodotAppleAuth::signOut() {
    [AppleProvider.shared signOut];
}

void GodotAppleAuth::credential() {
    [AppleProvider.shared credential];
}
