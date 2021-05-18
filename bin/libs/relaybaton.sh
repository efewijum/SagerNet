#!/usr/bin/env bash

source "bin/init/env.sh"

OUTPUT="relaybaton"
LIB_OUTPUT="lib$OUTPUT.so"
AAR_OUTPUT="$OUTPUT.aar"
ROOT="$PROJECT/rb-plugin/src/main/jniLibs"

git submodule update --init 'rb-plugin/*'
cd $PROJECT/rb-plugin/src/main/go/relaybaton

export GO111MOD=on
export CGO_ENABLED=1

export GO_ROOT="$(go env GOPATH)/src/github.com/cloudflare/go"
[ -d "$GO_ROOT" ] || git clone https://github.com/cloudflare/go.git "$GO_ROOT"
pushd $GO_ROOT/src
./make.bash || exit 1
popd

go mod download -x || exit 1

export GOOS=android
DIR="$ROOT/armeabi-v7a"
mkdir -p $DIR
env GOROOT="$GO_ROOT" CC=$ANDROID_ARM_CC GOARCH=arm GOARM=7 go build -x -o $DIR/$LIB_OUTPUT -trimpath -ldflags="-s -w -buildid=" $PWD/cmd/cli/main.go || exit 1
$ANDROID_ARM_STRIP $DIR/$LIB_OUTPUT

DIR="$ROOT/arm64-v8a"
mkdir -p $DIR
env GOROOT="$GO_ROOT" CC=$ANDROID_ARM64_CC GOARCH=arm64 go build -x -o $DIR/$LIB_OUTPUT -trimpath -ldflags="-s -w -buildid=" $PWD/cmd/cli/main.go
$ANDROID_ARM64_STRIP $DIR/$LIB_OUTPUT

DIR="$ROOT/x86"
mkdir -p $DIR
env GOROOT="$GO_ROOT" CC=$ANDROID_X86_CC GOARCH=386 go build -x -o $DIR/$LIB_OUTPUT -trimpath -ldflags="-s -w -buildid=" $PWD/cmd/cli/main.go
$ANDROID_X86_STRIP $DIR/$LIB_OUTPUT

DIR="$ROOT/x86_64"
mkdir -p $DIR
env GOROOT="$GO_ROOT" CC=$ANDROID_X86_64_CC GOARCH=amd64 go build -x -o $DIR/$LIB_OUTPUT -trimpath -ldflags="-s -w -buildid=" $PWD/cmd/cli/main.go
$ANDROID_X86_64_STRIP $DIR/$LIB_OUTPUT
