use_frameworks!
inhibit_all_warnings!

target 'Swift Rust FFI' do
	pod 'Alamofire', '~> 5.1'
	pod "PromiseKit", "~> 6.8"
	pod 'SwiftSocket', :git => 'https://github.com/swiftsocket/SwiftSocket', commit: '4a3af2cbbaef5b2fddbaff80f6767fecc0ce5fe2'

	target 'Swift Rust FFITests' do
		inherit! :complete
  end
end