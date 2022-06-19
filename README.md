# manage_entry

An application to detect text in an number plate and then storing it to firebase.

## **IMPORTANT**

1. For Camera Module, change the variable in android.defaultConfig.minSdkVersion to 23 in android/app/build.gradle file
1. For Firebase Module, first register your app on console.firebase.google.com and download and download the config file and put it in the android/app directory. Now add `classpath 'com.google.gms:google-services:4.3.3'` to buildscript.dependencies in android/build.gradle file AND add `implementation 'com.google.firebase:firebase-analytics:17.2.2'` to dependencies and `apply plugin: 'com.google.gms.google-services'` at the end of the file in android/app/build.gradle
