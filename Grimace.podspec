Pod::Spec.new do |s|
  s.name             = 'Grimace'
  s.version          = '0.1.0'
  s.summary          = 'Make it easier to use face stickers.'

  s.description      = <<-DESC
    Make it easier to use face stickers
                       DESC

  s.homepage         = 'https://github.com/Wzxhaha/Grimace'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'wzxjiang' => 'wzxjiang@foxmail.com' }
  s.source           = { :git => 'https://github.com/Wzxhaha/Grimace.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Grimace/Classes/**/*'
  s.frameworks = 'UIKit', 'CoreMedia', 'AVFoundation', 'CoreMotion'
  s.dependency 'GPUImage'
end
