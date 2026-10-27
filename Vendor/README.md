# MediaRemoteAdapter

Vendored copy of [ungive/mediaremote-adapter](https://github.com/ungive/mediaremote-adapter),
commit `0e82bf1c44ec39554fbfc402ec88a48c6ae2a0fd`, licensed under the BSD 3-Clause License (see
`MediaRemoteAdapter.LICENSE`).

The prebuilt `MediaRemoteAdapter.framework` is a universal binary
(`arm64` + `x86_64`) and is loaded by `/usr/bin/perl` through
`mediaremote-adapter.pl`. It is not linked to the app.

To rebuild the framework from the upstream sources:

```bash
clang -dynamiclib -fobjc-arc -fvisibility=default \
  -arch arm64 -arch x86_64 \
  -isysroot "$(xcrun --show-sdk-path)" -mmacosx-version-min=14.0 \
  -Iinclude -Isrc \
  src/adapter/*.m src/private/MediaRemote.m src/utility/*.m \
  -framework Foundation -framework AppKit -framework UniformTypeIdentifiers \
  -install_name @rpath/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter \
  -o MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter
```

The framework needs the standard `Versions/A` layout, an `Info.plist`, and
ad-hoc signing before it is copied into the app bundle.
