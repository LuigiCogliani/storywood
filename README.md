# irina_storywood_mockup

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# All the apple bits
## Auth key
### Name:storywood
### Key ID:8XZJ2NX64B
### Services:Apple Push Notifications service (APNs)
- [FlutterFire Overview](https://firebase.flutter.dev/docs/overview/#initialization)
- [iOS Installation](https://firebase.flutter.dev/docs/manual-installation/ios/)
- [Flutter: Firebase has not been correctly initialized](https://stackoverflow.com/questions/70627695/flutter-firebase-has-not-been-correctly-initialized)
- [How to Setup Xcode for Push Notifications](https://www.youtube.com/watch?v=oKTsjtHKSes)

# Build Android apk file
### 0. make sure that you are in the main branch and you pull the latest version / pushed the latest changes
### 1. In the terminal tipe *flutter build apk*
### 2. you will find the apk file in **build\app\outputs\apk\release**

#Apple deployment

https://docs.flutter.dev/deployment/ios

When asked in TestFlight about Missing compliance, select:
1. Standard encryption
2. Will not be available in France

#### Apple TestFlight
[Apple TestFlight official page](https://developer.apple.com/testflight/)


# Addressing multipe versions of the app
### When working with an app that is live it is common practice to have [3 environments](https://medium.com/@alifyandra/how-i-separate-development-environments-on-firestore-cf512a6afb7b):
1. dev, which is where you write new features with ad hoc data
2. staging, which is where you test the feature on a copy of your real database
3. production, where you current version of the app runs and where your users' data will be stored
### There are 3 ways of achieving this:
### a. Three separate projects in Firebase. This require several different config files in the codebase, for both ios and android, which can be difficult to do
### 
### b. Use **_dev**, **_stag**, and **_prod** suffixes: you have the same collections in Firebase replicated 3 times
![Alt text](https://miro.medium.com/v2/resize:fit:640/format:webp/1*382_lC33UOhV1mXEQpV9rA.png "a title")
### 
### c. Similar to solution b, [create 3 collections at root level](https://stackoverflow.com/questions/48649120/how-to-create-multi-environment-dbs-with-firestore/51510038#51510038) called **development**, **staging**, and **production**:
```
dev -> users -> details
    -> others_collection -> details

stag -> users
     -> others_collection -> details

prod -> users
     -> others_collection -> details
```


### There are several things to lookout for when adding a new feature. A common issue is when users do not update their app, leading to unexpected behaviours (e.g. we roll out an "archive tip" feature, where the new code looks for a ew data field, but the old code does not). [A few ways to address the problem](https://gilbouhnick.medium.com/the-long-tail-of-mobile-apps-3fe08e8de134):
1. **Force Upgrade:** prevent the users to use the app until they update. Ideal for early stages app, but likely to cause churn with a larg, established user base
2. **Backward compatibility:** have both versions of the code and detect the version of the app. In the "archive tip" example, when the app launches detects the version it's running. If the app is the old version, then it will use the previous code snippet, prevenint unexpected behaviour. This is not the developers choice, as it requires more focus and effort, but prevents users churn

