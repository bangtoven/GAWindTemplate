#
# Be sure to run `pod lib lint GAWindTemplate.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GAWindTemplate"
  s.version          = "0.1.0"
  s.summary          = "Template for wind instruments."
  s.homepage         = "http://cat.snu.ac.kr:8000/iOS/gawindtemplate"
  s.license          = 'MIT'
  s.author           = { "Jungho Bang" => "me@bangtoven.com" }
  s.source           = { :git => "http://cat.snu.ac.kr:8000/iOS/gawindtemplate.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'GAWindTemplate' => ['Pod/Assets/*']
  }

    s.dependency 'STK', '~> 4.5.2'
    s.dependency 'TheAmazingAudioEngine', '~> 1.4.6'
end
