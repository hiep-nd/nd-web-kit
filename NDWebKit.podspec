Pod::Spec.new do |s|
s.name         = "NDWebKit"
  s.version      = "0.0.1"
  s.summary      = "Utility for WebKit."
  s.description  = <<-DESC
  NDWebKit is a small utility framework for WebKit.
                   DESC
  s.homepage     = "https://github.com/hiep-nd/nd-web-kit.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Nguyen Duc Hiep" => "hiep.nd@gmail.com" }
  s.ios.deployment_target = '9.0'
  #s.tvos.deployment_target = '9.0'
  s.swift_versions = ['4.0', '5.1', '5.2']
  #s.source        = { :http => 'file:' + URI.escape(__dir__) + '/' }
  s.source       = { :git => "https://github.com/hiep-nd/nd-web-kit.git", :tag => "Pod-#{s.version}" }
  s.source_files  = "NDWebKit/**/*.{h,m,mm,swift}"
  s.public_header_files = "NDWebKit/**/*.h"
  s.header_mappings_dir = 'NDWebKit'
  s.framework = 'WebKit'
  s.dependency 'NDLog', '~> 0.0.5'
  s.dependency 'NDModificationOperators', '~> 0.0.2'
  s.dependency 'NDUtils/Foundation', '~> 0.0.4'
  s.dependency 'NDUtils/libextobjc', '~> 0.0.4'
  s.dependency 'NDUtils/objc', '~> 0.0.4'
end
