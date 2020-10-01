#
# Be sure to run `pod lib lint LispCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LispCore'
  s.version          = '0.1.0'
  s.summary          = 'Small lisp implementation on swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/puliaiev/LispMac'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Serhii Puliaiev' => 'serj1903@gmail.com' }
  s.source           = { :git => 'https://github.com/puliaiev/LispMac.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.13'

  s.source_files = 'LispCore/Classes/**/*'
  s.swift_version = '3.2'

  s.resource_bundles = {
    'LispCoreResources' => ['LispCore/Assets/*.lisp']
  }

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'LispCoreTests/*.swift'
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
