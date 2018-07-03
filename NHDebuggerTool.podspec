

Pod::Spec.new do |s|


  s.name         = "NHDebuggerTool"
  s.version      = "0.0.1"
  s.summary      = "ios 项目调试工具"
  s.description  = <<-DESC
                 "ios 项目调试工具,便于开发调试"
                 DESC
  s.homepage     = "http://www.baidu.com"
  s.license      = { :type => "BSD", :file => "LICENSE" }
  s.author             = { "neghao" => "neghao@126.com" }
  s.social_media_url   = "http://twitter.com/NegHao"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/NegHao/NHDebuggerTool.git", :tag => "#{s.version}"  }
  s.source_files  = "NHDebuggerTool/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.libraries = [ "sqlite3", "z" ]
  s.frameworks  = [ "Foundation", "UIKit", "CoreGraphics" ]
  # s.public_header_files = "Classes/**/*.h"

  # s.dependency "JSONKit", "~> 1.4"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  # s.library   = "iconv"
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }


end
