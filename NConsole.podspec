
Pod::Spec.new do |spec|
  spec.name         = "NConsole"
  spec.version      = "0.0.1"
  spec.summary      = "A Logger for iOS, macOS, tvOS, watchOS."

  spec.description  = <<-DESC
  A Logger for iOS, macOS, tvOS, watchOS.
                   DESC

  spec.homepage     = "https://github.com/nghinv-software/nconsole-ios"
  spec.screenshots  = "https://github.com/nghinv-software/nconsole-ios/demo_nconsole.png"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "NghiNV" => "nguyennghidt6@gmail.com" }

  spec.ios.deployment_target = '13.0'
  # spec.osx.deployment_target = '10.11'

  spec.source       = { :git => "https://github.com/nghinv-software/nconsole-ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "nconsole/**/*.{h,m,swift}"

end
