module Fastlane
  module Actions
    module SharedValues
      ANDROID_SDK_DIR = :ANDROID_SDK_DIR
    end

    class AndroidSdkUpdateAction < Action
      def self.run(params)
        # Install Android-SDK
        if FastlaneCore::Helper.mac?
          require 'fastlane/plugin/brew'
          Actions::BrewAction.run(command: "cask ls --versions android-sdk || brew cask install android-sdk")
          sdk_path = File.realpath("../..", FastlaneCore::CommandExecutor.which("android"))
        elsif FastlaneCore::Helper.linux?
          sdk_path = File.expand_path(params[:linux_sdk_install_dir])
          if File.exist?("#{sdk_path}/tools/android")
            UI.message("Using existing android-sdk at #{sdk_path}")
          else
            UI.message("Downloading android-sdk to #{sdk_path}")
            FastlaneCore::CommandExecutor.execute(
              command: "/usr/bin/wget -O /tmp/android-sdk-tools.zip #{params[:linux_sdk_download_url]}",
              print_all: true, print_command: true)
            FastlaneCore::CommandExecutor.execute(
              command: "/usr/bin/unzip /tmp/android-sdk-tools.zip -d #{sdk_path}",
              print_all: true, print_command: true)
          end
        else
          UI.user_error! 'Your OS is currently not supported.'
        end

        require 'java-properties'
        properties = File.exist?("#{Dir.pwd}/gradle.properties") ? JavaProperties.load("#{Dir.pwd}/gradle.properties") : {}
        tools_version = params[:build_tools_version] || properties[:build_tools_version] || UI.user_error!('No build tools version defined.')
        sdk_version = params[:compile_sdk_version] || properties[:compile_sdk_version] || UI.user_error!('No compile sdk version defined.')

        # Determine SDK dir and the sdkmanager
        sdk_manager = File.expand_path("tools/bin/sdkmanager", sdk_path)
        Actions.lane_context[SharedValues::ANDROID_SDK_DIR] = sdk_path

        packages = params[:additional_packages]
        packages << "platforms;android-#{sdk_version}"
        packages << "build-tools;#{tools_version}"
        packages << "tools"
        packages << "platform-tools"

        # Install Packagaes
        UI.header("Install Android-SDK packages")

        unless File.exist?(sdk_manager)
          # In case an old SDK is installed without the sdkmanager
          UI.important("Installed Android-SDK tools are outdated.")
          Actions.sh "yes | android update sdk --no-ui --all --filter tools"
        end

        # Accept licenses for all available packages
        UI.important("Accepting licenses on your behalf!")
        FastlaneCore::CommandExecutor.execute(command: "yes | #{sdk_manager} --licenses",
                                              print_all: true,
                                              print_command: false)

        # Install packages
        UI.message("Installing packages...")
        packages.each { |package| UI.message("• #{package}") }
        FastlaneCore::CommandExecutor.execute(command: "yes | #{sdk_manager} '#{packages.join("' '")}'",
                                              print_all: true,
                                              print_command: false)

        if params[:update_installed_packages]
          UI.message("Updating all installed packages")
          # Ensure all installed packages are updated
          FastlaneCore::CommandExecutor.execute(command: "yes | #{sdk_manager} --update",
                                                print_all: true,
                                                print_command: false)
        end

        if params[:override_local_properties]
          UI.message("Override local.properties")
          JavaProperties.write({ :"sdk.dir" => sdk_path }, "#{Dir.pwd}/local.properties")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Install and update required Android-SDK packages"
      end

      def self.details
        [
          "The initial Android-SDK will be installed with Homebrew/Linuxbrew.",
          "Updates for the specified packages will be automatically installed.",
          "Instructions to configure 'compile_sdk_version' and 'build_tools_version': https://github.com/NovaTecConsulting/fastlane-plugin-android_sdk_update"
        ].join("\n")
      end

      def self.example_code
        [
          'android_sdk_update(
            additional_packages: ["extras;google;m2repository", "extras;android;m2repository"]
          )',
          'android_sdk_update(
            compile_sdk_version: "25",
            build_tools_version: "25.0.2",
            additional_packages: ["extras;google;m2repository", "extras;android;m2repository"]
          )'
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :linux_sdk_install_dir,
                                       env_name: "FL_ANDROID_LINUX_SDK_INSTALL_DIR",
                                       description: "Install directory for Android SDK on Linux",
                                       optional: true,
                                       default_value: "~/android-sdk"),
          FastlaneCore::ConfigItem.new(key: :linux_sdk_download_url,
                                       env_name: "FL_ANDROID_LINUX_SDK_DOWNLOAD_URL",
                                       description: "Download URL for Android SDK on Linux",
                                       optional: true,
                                       default_value: "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"),
          FastlaneCore::ConfigItem.new(key: :compile_sdk_version,
                                       env_name: "FL_ANDROID_COMPILE_SDK_VERSION",
                                       description: "Compile-SDK Version of the project. Can also defined in 'gradle.properties'",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_tools_version,
                                       env_name: "FL_ANDROID_BUILD_TOOLS_VERSION",
                                       description: "Build-Tools Version of the project. Can also defined in 'gradle.properties'",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :additional_packages,
                                       description: "List with additional sdk packages. Examples:\n
                                      • extras;google;m2repository
                                      • extras;android;m2repository",
                                       is_string: false,
                                       optional: true,
                                       default_value: []),
          FastlaneCore::ConfigItem.new(key: :override_local_properties,
                                       env_name: "FL_ANDROID_SDK_OVERRIDE_LOCAL_PROPERTIES",
                                       description: "Set the sdk-dir in 'local.properties' so Gradle finds the Android home",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :update_installed_packages,
                                       env_name: "FL_ANDROID_SDK_UPDATE_INSTALLED_PACKAGES",
                                       description: "Update all installed packages to the latest versions",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['ANDROID_SDK_DIR', 'Path to the android sdk']
        ]
      end

      def self.authors
        ["Philipp Burgk", "Michael Ruhl"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
