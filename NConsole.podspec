
Pod::Spec.new do |spec|
  spec.name         = "NConsole"
  spec.version      = "1.0.0"
  spec.summary      = "A Logger for iOS, macOS, tvOS, watchOS."

  spec.description  = <<-DESC
  The NConsole is a simple logger for iOS, macOS, tvOS, watchOS. It is easy to use and easy to show your log in console.
                   DESC

  spec.homepage     = "https://github.com/nghinv-software/nconsole-ios"
  spec.screenshots  = "https://github.com/nghinv-software/nconsole-ios/blob/main/demo_nconsole.png"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "NghiNV" => "nguyennghidt6@gmail.com" }

  spec.ios.deployment_target = '13.0'
  # spec.osx.deployment_target = '10.11'

  spec.source       = { :git => "https://github.com/nghinv-software/nconsole-ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "nconsole/**/*.{h,m,swift}"

end
