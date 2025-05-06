# RichTextEditorKit.podspec

Pod::Spec.new do |s|

  # ―― Metadata ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name             = 'RichTextEditorKit'
  s.version          = '0.1.0' # Start with an initial version
  s.summary          = 'A reusable Rich Text Editor component for iOS.'
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  s.description      = <<-DESC
                       RichTextEditorKit provides a customizable and extensible rich text editing
                       experience for iOS applications, built with Swift and UIKit. Inspired by
                       AztecEditor-iOS. (TODO: Add more detail here)
                       DESC
  s.homepage         = 'https://github.com/YOUR_GITHUB_USERNAME/RichTextEditorKitProject' # TODO: Replace with your actual repo URL
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' } # TODO: Replace with your info

  # ―― Platform Support ――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform         = :ios # Specify platform
  s.ios.deployment_target = '13.0' # Set your minimum deployment target

  # ―― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――― #
  # For actual release, point to your git repo and tag.
  # For local development, this doesn't strictly matter as the ExampleApp's Podfile uses :path
  s.source           = { :git => 'https://github.com/YOUR_GITHUB_USERNAME/RichTextEditorKitProject.git', :tag => s.version.to_s }
  # TODO: Replace with your actual repo URL when ready to publish

  # ―― Source Code Files ――――――――――――――――――――――――――――――――――――――――――――――――― #
  # This pattern should match the location of your framework's Swift source files
  # relative to this .podspec file.
  s.source_files = 'RichTextEditorKit/Sources/**/*.swift'

  # ―― Resources (Optional) ―――――――――――――――――――――――――――――――――――――――――――――― #
  # If you have assets (images, xibs, strings files) inside RichTextEditorKit/Resources
  # Use resource_bundles to avoid naming conflicts.
  # s.resource_bundles = {
  #   'RichTextEditorKitResources' => ['RichTextEditorKit/Resources/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,strings}']
  # }
  # If you just have loose resources (less common now):
  # s.resources = 'RichTextEditorKit/Resources/**/*'

  # ―― Headers (If needed for Obj-C interop) ――――――――――――――――――――――――――――― #
  # If your umbrella header or other public headers are needed.
  # Ensure the header is inside the source_files path or define a headers path.
  # Let's assume you moved RichTextEditorKit.h into RichTextEditorKit/Sources/include/
  # s.public_header_files = 'RichTextEditorKit/Sources/include/**/*.h'
  # s.module_map = 'RichTextEditorKit/Sources/include/module.modulemap' # If you have a custom module map

  # If RichTextEditorKit.h remains directly in RichTextEditorKit/Sources/
  # s.public_header_files = 'RichTextEditorKit/Sources/RichTextEditorKit.h' # Might need adjustment based on final location

  # ―― Build Settings & Frameworks ――――――――――――――――――――――――――――――――――――― #
  s.frameworks = 'UIKit', 'Foundation' # List system frameworks your code depends on
  # s.dependency 'OtherPod', '~> 1.0' # Add any external pod dependencies here

  s.swift_version = '5.0' # Specify the Swift version compatibility

end