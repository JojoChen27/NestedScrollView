# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'NestedScrollView' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NestedScrollView
  pod 'NestedScrollViewController', :path => './'
  
  pod 'Parchment', '~> 3.2'
  pod 'LookinServer', :configurations => ['Debug']
  pod 'EasySwiftHook'
end

post_install do |installer|
  # Set default deployment target
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
