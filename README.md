<a title="Made with Fluent Design" href="https://github.com/bdlukaa/fluent_ui">
  <img
    src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=7A7574&labelColor=0078D7"
  />
</a>

# Second SSH

A quick way to manage your SSH Hosts

## Install

This app is available on the [Windows Store](https://www.microsoft.com/store/productId/9NWS9K95NMJB).

or 

as a direct download from the [Releases](https://github.com/bostrot/wsl2-distro-manager/releases) page.

## Build

Enable Flutter Desktop `flutter config --enable-windows-desktop`

https://flutter.dev/desktop

Run with `flutter run -d windows` and build with `flutter build windows`

## How to use

Fairly simple. Download the latest release from the releases Page and start second_ssh.exe

## FAQ


## Stuff

```
This project is made with [Flutter](https://flutter.dev/docs) for Desktop :)

VS2022: either use Flutter master branch or set `_cmakeVisualStudioGeneratorIdentifier` in `flutter_tools/lib/src/windows/build_windows.dart` to `Visual Studio 17 2022` and rebuild with `flutter pub run test`. (as of https://github.com/flutter/flutter/issues/85922)

Sign package for Windows Store: flutter build windows && flutter pub run msix:create
```
