//
//  GodotAppleAuth.h
//  GodotAppleAuth
//
//  Created by Oleksandr Kurtsev on 11/09/2021.
//

#import "core/engine.h"

#define PLUGIN_NAME "GodotAppleAuth"
#define PLUGIN_VERSION "1.0.0"

#define SIGNAL_CREDENTIAL "credential"
#define SIGNAL_AUTHORIZATION "authorization"

void init_godot_apple_auth();
void deinit_godot_apple_auth();

class GodotAppleAuth : public Object {
    
    GDCLASS(GodotAppleAuth, Object);
    static void _bind_methods();
    
public:
        
    void credential();
    bool isAvailable();
    
    void signIn();
    void signOut();
    
};
