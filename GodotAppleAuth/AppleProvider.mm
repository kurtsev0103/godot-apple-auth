//
//  AppleProvider.m
//  GodotAppleAuth
//
//  Created by Oleksandr Kurtsev on 11/09/2021.
//

#import "AppleProvider.h"
#import "AuthResult.h"
#import <CommonCrypto/CommonCrypto.h>

@interface AppleProvider ()

@property (nonatomic, strong) NSString* currentNonce;

@end

@implementation AppleProvider

+ (instancetype)shared {
    static AppleProvider *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [AppleProvider new];
    });
    return shared;
}

- (void)signIn {
    self.currentNonce = [self randomNonce:32];
    ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
    ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    request.nonce = [self stringBySha256HashingString:self.currentNonce];
    
    ASAuthorizationController *authorizationController =
    [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    authorizationController.presentationContextProvider = self;
    authorizationController.delegate = self;
    [authorizationController performRequests];
}

- (void)signOut {
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    [userDefaults setValue:nil forKey:@"appleAuthorizedUserIdKey"];
}

- (void)credential {
    ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"appleAuthorizedUserIdKey"];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"appleAuthorizedUserIdKey"] == nil) {
        AuthResult::credential(ASAuthorizationAppleIDProviderCredentialNotFound);
        return;
    }
    
    [appleIDProvider getCredentialStateForUserID:user completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
        if (error != nil) {
            AuthResult::credential_error(error.localizedDescription);
            return;
        }
        
        AuthResult::credential(credentialState);
    }];
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding -

- (nonnull ASPresentationAnchor)presentationAnchorForAuthorizationController:(nonnull ASAuthorizationController *)controller {
    NSPredicate *isKeyWindow = [NSPredicate predicateWithFormat:@"isKeyWindow == YES"];
    return [[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate:isKeyWindow].firstObject;
}

#pragma mark - ASAuthorizationControllerDelegate -

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        
        NSString *rawNonce = self.currentNonce;
        NSAssert(rawNonce != nil, @"Invalid state: A login callback was received, but no login request was sent.");
        
        if (appleIDCredential.identityToken == nil) {
            AuthResult::auth_error(@"Unable to fetch identity token.");
            return;
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:appleIDCredential.user forKey:@"appleAuthorizedUserIdKey"];
        
        NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
        
        if (idToken == nil) {
            AuthResult::auth_error(@"Unable to serialize id token from data.");
            return;
        }
        
        AuthResult::authorization(appleIDCredential, idToken);
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
    AuthResult::auth_error(error.localizedDescription);
}

#pragma mark - Nonce Creator Helper -

- (NSString *)randomNonce:(NSInteger) length {
    NSAssert(length > 0, @"Expected nonce to have positive length");
    NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
    NSMutableString *result = [NSMutableString string];
    NSInteger remainingLength = length;
    
    while (remainingLength > 0) {
        NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
        for (NSInteger i = 0; i < 16; i++) {
            uint8_t random = 0;
            
            int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
            NSAssert(errorCode == errSecSuccess, @"Unable to generate nonce: OSStatus %i", errorCode);
            
            [randoms addObject:@(random)];
        }
        
        for (NSNumber *random in randoms) {
            if (remainingLength == 0) { break; }
            
            if (random.unsignedIntValue < characterSet.length) {
                unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
                [result appendFormat:@"%C", character];
                remainingLength--;
            }
        }
    }
    return result;
}

- (NSString *)stringBySha256HashingString:(NSString *) str {
    const char *string = [str UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, (CC_LONG)strlen(string), result);
    
    NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hashed appendFormat:@"%02x", result[i]];
    }
    return hashed;
}

@end
