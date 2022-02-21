# manage_entry

A new Flutter project.

## **IMPORTANT**

1. For Camera Module, change the variable in android.defaultConfig.minSdkVersion to 23 in android/app/build.gradle file
1. For Firebase Module, first register your app on console.firebase.google.com and download and download the config file and put it in the android/app directory. Now add `classpath 'com.google.gms:google-services:4.3.3'` to buildscript.dependencies in android/build.gradle file AND add `implementation 'com.google.firebase:firebase-analytics:17.2.2'` to dependencies and `apply plugin: 'com.google.gms.google-services'` at the end of the file in android/app/build.gradle

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
