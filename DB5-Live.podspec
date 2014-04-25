Pod::Spec.new do |s|
  s.name             = "DB5-Live"
  s.version          = "0.1.0"
  s.summary          = "DB5 with Live Reloading"
  s.license          = 'MIT'
  s.author           = { "Dimitri Stancioff" => "dstancioff@gmail.com" }
  s.source           = { :git => "https://github.com/dstancioff/DB5-Live.git", :tag => s.version.to_s }
  s.homepage           = "http://www.github.com/dstancioff/DB5-Live"
  s.platform            = :ios, '7.0'


  s.requires_arc = true

  s.source_files = 'Source'
  s.preserve_paths = "Source/*.sh"

end
