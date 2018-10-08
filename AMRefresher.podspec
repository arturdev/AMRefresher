#
# Be sure to run `pod lib lint AMRefresher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AMRefresher'
  s.version          = '1.0.0'
  s.summary          = 'Super easy way to use "Pull To Refresh" and "Infinite Scrolling" with 1 line of code'

  s.description      = <<-DESC
Super easy way to use "Pull To Refresh" and "Infinite Scrolling" with 1 line of code from arturdev
                       DESC

  s.homepage         = 'https://github.com/arturdev/AMRefresher'
  s.screenshots      = 'https://raw.githubusercontent.com/arturdev/AMRefresher/master/demo.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arturdev' => 'mkrtarturdev@gmail.com' }
  s.source           = { :git => 'https://github.com/arturdev/AMRefresher.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  s.source_files = 'AMRefresher/*'
  s.swift_version = '4.1'
  s.frameworks = 'UIKit'
end
