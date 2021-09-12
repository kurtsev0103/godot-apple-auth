# GodotAppleAuth
Plugin for authorization with Apple for Godot Game Engine

## Installation

1. [Download Plugin](https://github.com/kurtsev0103/godot-apple-auth/releases/download/1.0.0/GodotAppleAuth_plugin.zip), unzip and copy files to your Godot project's ```res://ios/plugins``` directory. You can also group files in a sub-directory, like ```res://ios/plugins/godot_apple_auth```
2. You can find and activate plugin by going to Project -> Export... -> iOS and in the Options tab, scrolling to the Plugins section. 
<img width="430" alt="img" src="https://user-images.githubusercontent.com/27446881/132978224-f9024d35-fb54-46d6-85db-3a6e8fae036b.png">

## Samples and Example Usage

Description

> Methods
```gdscript
# Checking for support of the current Apple Sign-in platform 
is_available() -> bool
# Check the status of authentication
credential() -> void
# Sign in with apple
sign_in() -> void
# Sign out with apple
sign_out() -> void
```

> Signals
```gdscript
credential(result: Dictionary)
authorization(result: Dictionary)
```

Initialization
```gdscript
var godot_apple_auth: Object

func _ready():
	if Engine.has_singleton("GodotAppleAuth"):
		godot_apple_auth = Engine.get_singleton("GodotAppleAuth")
		godot_apple_auth.connect("credential", self, "_on_credential")
		godot_apple_auth.connect("authorization", self, "_on_authorization")
```

Checking for support Apple Sign-in
```gdscript
# Call the method anywhere in the code
if godot_apple_auth.is_available():
	print("available")
```

Checking credential status
```gdscript
# 1. Call the method anywhere in the code
godot_apple_auth.credential()
# 2. Wait for the answer in the method below
func _on_credential(result: Dictionary):
	if result.has("error"):
		print(result.error)
	else:
		print(result.state)
		# "authorized" <- user ID is in good state
		# "not_found" <- user ID was not found
		# "revoked" <- user ID was revoked by the user
```

Sign In
```gdscript
# 1. Call the method anywhere in the code
godot_apple_auth.sign_in()
# 2. Wait for the answer in the method below
func _on_credential(result: Dictionary):
	if result.has("error"):
		print(result.error)
	else:
		# Required
		print(result.token)
		print(result.user_id)
		# Optional (can be empty)
		print(result.email)
		print(result.name)
```

Sign Out
```gdscript
# Call the method anywhere in the code
godot_apple_auth.sign_out()
```

## Created by Oleksandr Kurtsev (Copyright © 2021) [LICENSE](https://github.com/kurtsev0103/godot-apple-auth/blob/main/LICENSE)
