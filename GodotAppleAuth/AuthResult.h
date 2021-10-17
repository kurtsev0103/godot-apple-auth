//
//  AuthResult.h
//  GodotAppleAuth
//
//  Created by Oleksandr Kurtsev on 11/09/2021.
//

#import <Foundation/Foundation.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import "core/engine.h"

class AuthResult {
    
public:
    
    static void auth_error(NSString* error);
    static void credential_error(NSString* error);
    
    static void authorization(ASAuthorizationAppleIDCredential* credential, NSString* token) API_AVAILABLE(ios(13.0));
    static void credential(ASAuthorizationAppleIDProviderCredentialState state) API_AVAILABLE(ios(13.0));
    
};
