Pod::Spec.new do |s|
  s.name             = 'BlowMindStyle'
  s.version          = '0.9.0'
  s.summary          = 'Framework that will help to orginize styles in your app.'
  s.description      = <<-DESC
Framework that will help to orginize styles in your app. Requires swift 5.1 and XCode 11.
                       DESC
  s.homepage         = 'https://github.com/BlowMindStyle/BlowMindStyle'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gotyanov' => 'Aleksey.Gotyanov@gmail.com' }
  s.source           = { :git => 'https://github.com/BlowMindStyle/BlowMindStyle.git', :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/BlowMindStyle/**/*.swift'
  s.swift_version = '5.1'

  s.dependency 'RxSwift', '> 4.5'
  s.dependency 'RxCocoa', '> 4.5'
end
