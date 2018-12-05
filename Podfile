# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SmartContrakt' do
  use_frameworks!

  pod 'SWXMLHash', '~> 4.7.0'
  pod 'DrawerController', '~> 4.0'
  pod 'RMDateSelectionViewController', '~> 2.3'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'DrawerController'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end

    end
end
