Pod::Spec.new do |s|
  s.name         = "BuildConfig.swift"
  s.version      = "3.0.0"
  s.summary      = "Auto-generated BuildConfig for macOS/iOS"

  s.description  = <<-DESC
                  BuildConfig.swift is a tool to get strong typed configuration from yamls/jsons.
                  DESC

  s.homepage     = "https://github.com/417-72KI/BuildConfig.swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "417.72KI" => "417.72ki@gmail.com" }
  s.social_media_url   = "http://twitter.com/417_72KI"

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "10.0"

  s.requires_arc = true
  
  s.source        = { :http => "https://github.com/417-72KI/BuildConfig.swift/releases/download/#{s.version}/buildconfigswift.zip" }
  s.preserve_paths = "buildconfigswift"
end
