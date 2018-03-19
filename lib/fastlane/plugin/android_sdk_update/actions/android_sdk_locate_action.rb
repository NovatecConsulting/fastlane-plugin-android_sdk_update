module Fastlane
  module Actions
    module SharedValues
      ANDROID_SDK_DIR = :ANDROID_SDK_DIR
    end

    class AndroidSdkLocateAction < Action
      def self.run(params)
        # Locate (and install) Android-SDK
        if FastlaneCore::Helper.mac?
          require 'fastlane/plugin/brew'
          Actions::BrewAction.run(command: "cask ls --versions android-sdk || brew cask install android-sdk")
          sdk_path = File.realpath("../../..", FastlaneCore::CommandExecutor.which("sdkmanager"))
        elsif FastlaneCore::Helper.linux?
          sdk_path = File.expand_path(params[:linux_sdk_install_dir])
          if File.exist?("#{sdk_path}/tools/sdkmanager")
            UI.message("Using existing android-sdk at #{sdk_path}")
          else
            UI.message("Downloading android-sdk to #{sdk_path}")
            download_and_extract_sdk(params[:linux_sdk_download_url], sdk_path)
          end
        else
          UI.user_error! 'Your OS is currently not supported.'
        end
        # set environment variable so can be picked up by CI
        ENV['ANDROID_SDK_DIR'] = sdk_path
        Actions.lane_context[SharedValues::ANDROID_SDK_DIR] = sdk_path
      end

      def self.download_and_extract_sdk(download_url, sdk_path)
        FastlaneCore::CommandExecutor.execute(
          command: "wget -O /tmp/android-sdk-tools.zip #{download_url}",
          print_all: true, print_command: true)
        FastlaneCore::CommandExecutor.execute(
          command: "unzip /tmp/android-sdk-tools.zip -d #{sdk_path}",
          print_all: true, print_command: true)
      end

      def self.download_and_extract_sdk(download_url, sdk_path)
        FastlaneCore::CommandExecutor.execute(
          command: "wget -O /tmp/android-sdk-tools.zip #{download_url}",
          print_all: true, print_command: true)
        FastlaneCore::CommandExecutor.execute(
          command: "unzip /tmp/android-sdk-tools.zip -d #{sdk_path}",
          print_all: true, print_command: true)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Locate or install main Android SDK"
      end

      def self.details
        [
          "The initial Android-SDK will be installed with Homebrew (mac) or downloaded & unzipped (Linux).",
        ].join("\n")
      end

      def self.example_code
        [
          'android_sdk_locate',
          'android_sdk_locate(
            linux_sdk_install_dir: "/usr/local/android-sdk",
            linux_sdk_download_url: "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
          )'
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :linux_sdk_install_dir,
                                       env_name: "FL_ANDROID_LINUX_SDK_INSTALL_DIR",
                                       description: "Install directory for Android SDK on Linux",
                                       optional: true,
                                       default_value: ENV['ANDROID_HOME'] || ENV['ANDROID_SDK_ROOT'] || ENV['ANDROID_SDK_DIR'] || "~/.android-sdk"),
          FastlaneCore::ConfigItem.new(key: :linux_sdk_download_url,
                                       env_name: "FL_ANDROID_LINUX_SDK_DOWNLOAD_URL",
                                       description: "Download URL for Android SDK on Linux",
                                       optional: true,
                                       default_value: "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip")
        ]
      end

      def self.output
        [
          ['ANDROID_SDK_DIR', 'Path to the android sdk']
        ]
      end

      def self.authors
        ["Philipp Burgk", "Michael Ruhl", "adamcohenrose"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
