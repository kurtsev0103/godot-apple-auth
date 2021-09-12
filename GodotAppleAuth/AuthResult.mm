//
//  AuthResult.m
//  GodotAppleAuth
//
//  Created by Oleksandr Kurtsev on 11/09/2021.
//

#import "AuthResult.h"
#import "GodotAppleAuth.h"
#import "core/engine.h"

void AuthResult::authorization(ASAuthorizationAppleIDCredential* credential, NSString* token) {
    Dictionary result = Dictionary();
    result["token"] = String(token.UTF8String);
    result["email"] = String(credential.email.UTF8String);
    result["user_id"] = String(credential.user.UTF8String);
    result["name"] = "";
    
    NSString *firstName = credential.fullName.givenName;
    NSString *lastName = credential.fullName.familyName;
    
    if (firstName.length > 0 && lastName.length > 0) {
        result["name"] = String([NSString stringWithFormat:@"%@ %@", firstName, lastName].UTF8String);
    } else if (credential.fullName.givenName.length > 0) {
        result["name"] = String([NSString stringWithFormat:@"%@", firstName].UTF8String);
    } else if (credential.fullName.familyName.length > 0)
        result["name"] = String([NSString stringWithFormat:@"%@", lastName].UTF8String);
    
    Engine::get_singleton()->get_singleton_object(String(PLUGIN_NAME))->emit_signal(String(SIGNAL_AUTHORIZATION), result);
}

void AuthResult::credential(ASAuthorizationAppleIDProviderCredentialState state) {
    Dictionary result = Dictionary();
    
    switch (state) {
        case ASAuthorizationAppleIDProviderCredentialAuthorized:
            result["state"] = String(@"authorized".UTF8String);
            break;
        case ASAuthorizationAppleIDProviderCredentialNotFound:
            result["state"] = String(@"not_found".UTF8String);
            break;
        default:
            result["state"] = String(@"revoked".UTF8String);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setValue:nil forKey:@"appleAuthorizedUserIdKey"];
            });
            break;
    }
    
    Engine::get_singleton()->get_singleton_object(String(PLUGIN_NAME))->emit_signal(String(SIGNAL_CREDENTIAL), result);
}

void AuthResult::auth_error(NSString* error) {
    Dictionary result = Dictionary();
    result["error"] = String(error.UTF8String);
    Engine::get_singleton()->get_singleton_object(String(PLUGIN_NAME))->emit_signal(String(SIGNAL_AUTHORIZATION), result);
}

void AuthResult::credential_error(NSString* error) {
    Dictionary result = Dictionary();
    result["error"] = String(error.UTF8String);
    Engine::get_singleton()->get_singleton_object(String(PLUGIN_NAME))->emit_signal(String(SIGNAL_CREDENTIAL), result);
}
