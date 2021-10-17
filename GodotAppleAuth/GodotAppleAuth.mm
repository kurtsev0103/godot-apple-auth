//
//  GodotAppleAuth.m
//  GodotAppleAuth
//
//  Created by Oleksandr Kurtsev on 11/09/2021.
//

#import "GodotAppleAuth.h"
#import "AppleProvider.h"
#import "AuthResult.h"

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
    ClassDB::bind_method(D_METHOD("is_available"), &GodotAppleAuth::isAvailable);
    
    ADD_SIGNAL(MethodInfo(String(SIGNAL_CREDENTIAL), PropertyInfo(Variant::DICTIONARY, "result")));
    ADD_SIGNAL(MethodInfo(String(SIGNAL_AUTHORIZATION), PropertyInfo(Variant::DICTIONARY, "result")));
}

GodotAppleAuth::GodotAppleAuth() {}

GodotAppleAuth::~GodotAppleAuth() {}

#pragma mark - Implementation -

void GodotAppleAuth::signIn() {
    if (@available(iOS 13.0, *)) {
        [AppleProvider.shared signIn];
    } else {
        AuthResult::auth_error(@"Apple authentication is not supported.");
    }
}

void GodotAppleAuth::signOut() {
    if (@available(iOS 13.0, *)) {
        [AppleProvider.shared signOut];
    } else {
        AuthResult::auth_error(@"Apple authentication is not supported.");
    }
}

void GodotAppleAuth::credential() {
    if (@available(iOS 13.0, *)) {
        [AppleProvider.shared credential];
    } else {
        AuthResult::credential_error(@"Apple authentication is not supported.");
    }
}

bool GodotAppleAuth::isAvailable() {
    if (@available(iOS 13.0, *)) { return true; } else { return false; }
}
