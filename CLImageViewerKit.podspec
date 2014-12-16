
Pod::Spec.new do |s|

  s.name         = "CLImageViewerKit"
  s.version      = "0.0.0"
  s.summary      = "This is a collection of components for images and image views management."

  s.homepage     = "https://github.com/yackle/CLImageViewerKit"
  
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Sho Yakushiji" => "sho.yakushiji@gmail.com" }


  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/yackle/CLImageViewerKit.git", :tag => "v#{s.version}" }
  s.frameworks   = 'UIKit'
  
  
  s.subspec 'UIImagePlaceholder' do |a|
    a.source_files = 'Classes/UIImage+Placeholder/*.{h,m}'
  end
  s.subspec 'UIImageUtility' do |a|
    a.source_files = 'Classes/UIImage+Utility/*.{h,m}'
  end
  s.subspec 'UIViewFrame' do |a|
    a.source_files = 'Classes/UIView+Frame/*.{h,m}'
  end
  s.subspec 'UIColorPatterns' do |a|
    a.source_files = 'Classes/UIColor+Patterns/*.{h,m}'
  end
  s.subspec 'NSStringMD5Hash' do |a|
    a.source_files = 'Classes/NSString+MD5Hash/*.{h,m}'
  end
  
  
  
  s.subspec 'CLZoomingImageView' do |a|
    a.source_files = 'Classes/CLZoomingImageView/*.{h,m}'
  end
  s.subspec 'CLFullscreenImageViewer' do |a|
    a.source_files = 'Classes/CLFullscreenImageViewer/*.{h,m}'
    a.dependency 'CLImageViewerKit/CLZoomingImageView'
  end
  s.subspec 'CLImagePagingView' do |a|
    a.source_files = 'Classes/CLImagePagingView/*.{h,m}'
    a.dependency 'CLImageViewerKit/CLFullscreenImageViewer'
  end
  
  
  
  s.subspec 'UIImageViewURLDownload' do |a|
    a.source_files = 'Classes/UIImageView+URLDownload/*.{h,m}'
  end
  s.subspec 'CLCacheManager' do |a|
    a.source_files = 'Classes/CLCacheManager/*.{h,m}'
    a.dependency 'CLImageViewerKit/UIImageUtility'
    a.dependency 'CLImageViewerKit/NSStringMD5Hash'
  end
  s.subspec 'CLDownloadManager' do |a|
    a.source_files = 'Classes/CLDownloadManager/*.{h,m}'
    a.dependency 'CLImageViewerKit/NSStringMD5Hash'
  end
  s.subspec 'CLImageView' do |a|
    a.source_files = 'Classes/CLImageView/*.{h,m}'
    a.dependency 'CLImageViewerKit/UIImageViewURLDownload'
    a.dependency 'CLImageViewerKit/CLCacheManager'
    a.dependency 'CLImageViewerKit/CLDownloadManager'
  end
  
  
  
  s.subspec 'CLPickerView' do |a|
    a.source_files = 'Classes/CLPickerView/*.{h,m}'
    a.dependency 'CLImageViewerKit/UIViewFrame'
  end
  s.subspec 'CLFontPickerView' do |a|
    a.source_files = 'Classes/CLFontPickerView/*.{h,m}'
    a.dependency 'CLImageViewerKit/CLPickerView'
  end
  
  
  
  s.subspec 'CLColorPickerView' do |a|
    a.source_files = 'Classes/CLColorPickerView/*.{h,m}'
    a.dependency 'CLImageViewerKit/UIViewFrame'
  end
  
  
  
  s.subspec 'CLImagePicker' do |a|
    a.source_files = 'Classes/CLImagePicker/**/*.{h,m}'
    a.public_header_files = 'Classes/CLImagePicker/*/*.h'
    a.resources = 'Classes/CLImagePicker/**/*.xib', 'Classes/CLImagePicker/**/*.bundle'
    a.dependency 'CLImageViewerKit/UIViewFrame'
    a.dependency 'CLImageViewerKit/UIImageUtility'
    a.dependency 'CLImageViewerKit/CLZoomingImageView'
    a.dependency 'CLImageViewerKit/CLCacheManager'
    a.dependency 'CLImageEditor'
  end
  
end
