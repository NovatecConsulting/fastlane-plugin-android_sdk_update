describe Fastlane do
  describe Fastlane::FastFile do
    describe 'Android-SDK-Update Integration' do
      before :each do
        require 'fastlane/plugin/brew'
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end
      it 'fails without build tools version' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            android_sdk_update
          end").runner.execute(:test)
        end.to raise_error("No build tools version defined.")
      end
      it 'fails without compile sdk version' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            android_sdk_update({build_tools_version: '23'})
          end").runner.execute(:test)
        end.to raise_error("No compile sdk version defined.")
      end
      it 'updates android sdk' do
        values = Fastlane::FastFile.new.parse("lane :test do
            android_sdk_update({
              build_tools_version: '25.0.2',
              compile_sdk_version: '25'
            })
          end").runner.execute(:test)
      end
    end
  end
end
