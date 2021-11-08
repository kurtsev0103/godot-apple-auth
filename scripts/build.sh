#!/bin/bash

plugin_name=GodotAppleAuth

scons_version=3.x
godot_version=3.4

declare -a targets=(release release_debug)

# Checking the validity of version
function validating_version() {
  local version=${1}"-stable"

  cd ./godot || exit
  if [ $(git tag -l $version) ]; then
    godot_version=${1}
  fi
  cd ./../
}

# Checking for input parameters
while getopts v: flag
do
  case ${flag} in
    v) validating_version ${OPTARG};;
  esac
done

echo "$(tput setaf 2)=== Selected Godot version $(tput setaf 1)$godot_version"-stable" $(tput setaf 2)===$(tput sgr 0)"

# Checking for scons version
if [ ${godot_version:0:1} = 4 ]; then
  scons_version=4.0
fi

# Checkout Godot version
cd ./godot || exit
git checkout $godot_version"-stable"

# Generate Headers
./../scripts/timeout.sh scons platform=iphone target=release_debug --jobs=$(sysctl -n hw.logicalcpu)
cd ./../

# Compile static libraries
for target in ${targets[@]}
do
  scons plugin=$plugin_name target=$target version=$scons_version arch=arm64 --jobs=$(sysctl -n hw.logicalcpu)
  scons plugin=$plugin_name target=$target version=$scons_version arch=x86_64 simulator=yes --jobs=$(sysctl -n hw.logicalcpu)

  output=release
  if [ $target = release_debug ]; then
    output=debug
  fi

  lipo -create ./bin/lib$plugin_name.arm64-iphone.$target.a ./bin/lib$plugin_name.x86_64-simulator.$target.a -output ./bin/$plugin_name.$output.a
  rm ./bin/lib$plugin_name.arm64-iphone.$target.a
  rm ./bin/lib$plugin_name.x86_64-simulator.$target.a
done

# Archiving plugin
zip ./bin/"$plugin_name"_for_Godot_$godot_version.zip ./bin/$plugin_name.release.a ./bin/$plugin_name.debug.a ./$plugin_name.gdip

rm ./bin/$plugin_name.release.a
rm ./bin/$plugin_name.debug.a

echo "$(tput setaf 2)=== The plugin has been created in $(tput setaf 6)'bin' $(tput setaf 2)folder ===$(tput sgr 0)"
