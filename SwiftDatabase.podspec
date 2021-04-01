Pod::Spec.new do |s|

  s.name                  = 'SwiftDatabase'
  s.version               = '1.2.3'
  s.ios.deployment_target = '12.3'
  s.swift_versions        = ['5.0', '5.1', '5.2', '5.3', '5.4']
  s.author                = 'Ricardo Rauber Pereira'
  s.license               = 'MIT'
  s.homepage              = 'http://ricardorauber.com'
  s.source                = { :git => 'https://github.com/ricardorauber/SwiftDatabase.git', :tag => s.version }
  s.summary               = 'A light Swift database to use in your apps'
  s.pod_target_xcconfig   = { 'ENABLE_TESTABILITY' => 'YES' }
  s.source_files          = 'Classes/**/*'
  
  s.test_spec 'Tests' do |test_spec|
    test_spec.requires_app_host = true
    test_spec.source_files      = 'Tests/**/*'

    test_spec.dependency 'Nimble', '8.1.2'
    test_spec.dependency 'Quick',  '3.0.0'
  end
end
