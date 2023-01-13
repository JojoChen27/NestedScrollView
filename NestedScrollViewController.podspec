#
# Be sure to run `pod lib lint NestedScrollViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NestedScrollViewController'
  s.version          = '0.1.0'
  s.summary          = 'Nested scrollview controllers with smooth scrolling.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Nested scrollview controllers with smooth scrolling up and down.
                       DESC

  s.homepage         = 'https://github.com/Super-JJ/NestedScrollView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JJ' => 'cchao2627@163.com' }
  s.source           = { :git => 'https://github.com/Super-JJ/NestedScrollView.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  s.source_files = 'NestedScrollView/NestedScrollViewController/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Parchment', '~> 3.2'
end
