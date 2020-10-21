Pod::Spec.new do |s|
  s.name = 'LispCore'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'Common Lisp interpreter for macOS and iOS.'
  s.homepage = 'https://github.com/puliaiev/LispMac'
  s.authors = { 'Serhii Puliaiev' => 'http://puliaiev.com' }
  s.social_media_url = 'https://twitter.com/spuliaiev'
  s.source = { :git => 'https://github.com/puliaiev/LispMac.git', :tag => '0.1.0' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.15'

  s.source_files = 'Sources/LispCore/**/*.swift'
  s.resource_bundles = {
    'LispCore_LispCore' => ['Sources/LispCore/Resources/**/*.*']
  }
  
  s.swift_version = '5.3'
end
