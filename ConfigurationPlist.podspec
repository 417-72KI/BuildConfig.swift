Pod::Spec.new do |s|
  s.name         = "ConfigurationPlist"
  s.version      = "0.1.1-preview"
  s.summary      = "Generate Config.plist for macOS/iOS"

  s.description  = <<-DESC
                  ConfigurationPlist is a tool to generate Config.plist automatically.
                  Property List is a standard format in macOS/iOS, but also a bother to edit.
                  ConfigurationPlist can create Config.plist with merging yamls or jsons.
                   DESC

  s.homepage     = "https://github.com/417-72KI/ConfigurationPlist"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "417.72KI" => "417.72ki@gmail.com" }
  s.social_media_url   = "http://twitter.com/417_72KI"

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "10.0"

  s.requires_arc = true
  
  s.source        = { :http => "https://github.com/417-72KI/ConfigurationPlist/releases/download/#{s.version}/configurationPlist.zip" }
  s.preserve_paths = "configurationPlist"
end
