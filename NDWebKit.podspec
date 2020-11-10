Pod::Spec.new do |s|
s.name         = "NDWebKit"
  s.version      = "0.0.2"
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

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Core/*.{h,m,mm,swift}'

    ss.framework = 'WebKit'

    ss.dependency 'NDLog/ObjC', '~> 0.0.6'
    ss.dependency 'NDModificationOperators/ObjC', '~> 0.0.3'
    ss.dependency 'NDUtils/Foundation', '~> 0.0.5'
    ss.dependency 'NDUtils/libextobjc', '~> 0.0.5'
    ss.dependency 'NDUtils/objc', '~> 0.0.5'
  end

  s.subspec 'ObjC' do |ss|
    ss.dependency 'NDWebKit/Core'
  end

  s.subspec 'Swift' do |ss|
    ss.dependency 'NDWebKit/ObjC'
  end

  s.default_subspec = 'Swift'

end
