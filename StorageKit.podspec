Pod::Spec.new do |s|
  s.name             = 'StorageKit'
  s.version          = '0.1.0'
  s.summary          = 'Your Data Storage Troubleshooter'
  s.homepage         = 'https://github.com/storagekit/storagekit'
  s.license          = { :type => 'MIT', :file => 'LICENSE'}
  s.author           = { 'StorageKit' => 'storagekit@something.com'}
  s.source           = { :git => 'https://github.com/storageKit/storagekit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/**/*'
  s.exclude_files = 'Tests/*'
  s.dependency 'RealmSwift', '2.8.3'
end
