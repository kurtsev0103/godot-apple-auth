//
//  AppleProvider.h
//  GodotAppleAuth
//
//  Created by Oleksandr Kurtsev on 11/09/2021.
//

#import <Foundation/Foundation.h>
#import <AuthenticationServices/AuthenticationServices.h>

@interface AppleProvider : NSObject <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>

+ (instancetype)shared;

- (void)signIn;
- (void)signOut;
- (void)credential;

@end
