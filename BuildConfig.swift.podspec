Pod::Spec.new do |s|
  s.name         = "BuildConfig.swift"
  s.version      = ENV['POD_VERSION']
  s.summary      = "Auto-generated BuildConfig for macOS/iOS"

  s.description  = <<-DESC
                  BuildConfig.swift is a tool to get strong typed configuration from yamls/jsons.
                  DESC

  s.homepage     = "https://github.com/417-72KI/BuildConfig.swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "417.72KI" => "417.72ki@gmail.com" }
  s.social_media_url   = "http://twitter.com/417_72ki"

  s.ios.deployment_target = "15.0"
  s.osx.deployment_target = "12.0"
  s.watchos.deployment_target = "8.0"
  s.tvos.deployment_target = "15.0"

  s.requires_arc = true
  
  s.source         = { :http => "https://github.com/417-72KI/BuildConfig.swift/releases/download/#{s.version}/buildconfigswift-v#{s.version}.zip" }
  s.preserve_paths = "buildconfigswift"
end
