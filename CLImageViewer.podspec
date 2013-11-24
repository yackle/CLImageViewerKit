
Pod::Spec.new do |s|

  s.name         = "CLImageViewer"
  s.version      = "0.0.1"
  s.summary      = "This is a collection of components for images and image views management."

  s.homepage     = "https://github.com/yackle/CLImageViewer"
  
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Sho Yakushiji" => "sho.yakushiji@gmail.com" }


  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/yackle/CLImageViewer.git", :tag => "v#{s.version}" }
  
  s.subspec 'UIImagePlaceholder' do |a|
    a.source_files = 'Classes/UIImage+Placeholder/*.{h,m}'
  end
  s.subspec 'CLZoomingImageView' do |a|
    a.source_files = 'Classes/CLZoomingImageView/*.{h,m}'
  end
  s.subspec 'CLFullscreenImageViewer' do |a|
    a.source_files = 'Classes/CLFullscreenImageViewer/*.{h,m}'
    a.dependency 'CLImageViewer/CLZoomingImageView'
  end
  s.subspec 'CLImagePagingView' do |a|
    a.source_files = 'Classes/CLImagePagingView/*.{h,m}'
    a.dependency 'CLImageViewer/CLFullscreenImageViewer'
  end
end
