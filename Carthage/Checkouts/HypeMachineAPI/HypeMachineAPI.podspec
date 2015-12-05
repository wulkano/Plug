Pod::Spec.new do |s|
  s.name         = "HypeMachineAPI"
  s.version      = "0.4.2"
  s.summary      = "This is a partial implementation of the Hype Machine API in Swift."
  s.homepage     = "https://github.com/PlugForMac/HypeMachineAPI"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Alex Marchant" => "alexjmarchant@gmail.com" }
  s.platform     = :osx, "10.10"
  s.source       = { :git => "https://github.com/PlugForMac/HypeMachineAPI.git", :tag => s.version }
  s.source_files = 'Source/*.swift'
  s.requires_arc = true
  s.dependency "Alamofire", "~> 1.2.1"
end
