Pod::Spec.new do |spec|
  spec.name         = "LBScanView"
  spec.version      = "1.0.0"
  spec.summary      = "条形码二维码扫描"
  spec.description  = "集成系统扫描，支持二维码和条形码，同时返回扫描成功图片；以及图片二维码扫描（目前苹果自带API不支持图片扫描条形码），界面完全自定义。"
  spec.homepage     = "https://github.com/A1129434577/LBScanView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "刘彬" => "1129434577@qq.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.source       = { :git => 'https://github.com/A1129434577/LBScanView.git', :tag => spec.version.to_s }
  spec.source_files = "LBScanView/**/*.{h,m}"
  spec.requires_arc = true
end
