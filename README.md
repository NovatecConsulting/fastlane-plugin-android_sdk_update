# android_sdk_update plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-android_sdk_update)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-android_sdk_update`, add it to your project by running:

```bash
fastlane add_plugin android_sdk_update
```

## About android_sdk_update

Install and update required Android-SDK packages:

* The Android-SDK will be installed with Homebrew/Linuxbrew.
* Updates for the specified packages will be automatically installed.

## Example

```ruby
# With defined 'gradle.properties'- instructions below
android_sdk_update(
	additional_packages: ["extras;google;m2repository", "extras;android;m2repository"]
)

android_sdk_update(
	compile_sdk_version: "27",
	build_tools_version: "27.0.2",
	additional_packages: ["extras;google;m2repository", "extras;android;m2repository"]
)
```

## Instructions for compile_sdk_version and build_tools_version

In order to reference the same *compileSdkVersion* and *buildToolsVersion* as defined in your build.gradle, we are using the 'gradle.properties'.

First we set these versions in the property file

**gradle.properties**

```java
compile_sdk_version=27
build_tools_version=27.0.2
```

Now we can reference them in our gradle project

**build.gradle**

```groovy
android {
    compileSdkVersion project.compile_sdk_version.toInteger()
    buildToolsVersion project.build_tools_version
    ...
 }
 ```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
