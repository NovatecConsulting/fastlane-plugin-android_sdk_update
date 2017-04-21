module Fastlane
  module Helper
    class AndroidSdkUpdateHelper
      # class methods that you define here become available in your action
      # as `Helper::AndroidSdkUpdateHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the android_sdk_update plugin helper!")
      end
    end
  end
end
