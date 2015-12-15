Pod::Spec.new do |s|
  s.name         = 'Screencare'
  s.version      = '1.0.0'
  s.summary      = "Screencare helps to make app screenshots, annotate them and send to your team."
  s.description  = <<-DESC
                    This is an iOS library that can be integrated to your app to make screenshots with annotations and send them with your comments and user device info to a project management service like Basecamp or Slack
                   DESC
  s.homepage     = 'https://github.com/linkov/screencare'
  s.author       = { 'SDWR' => 'a.linkov@me.com' }
  s.source       = { :git => "git@github.com:linkov/screencare.git", :tag => s.version.to_s}
  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.framework    = 'JavaScriptCore'
  s.source_files = 'Library/ScreenCare/ScreenCare/**/*.{h,m}'
  s.resources = ['Library/ScreenCare/ScreenCare/images/*.png']
  s.requires_arc = true
  s.license      = { :type => "SDWR License", :file => "LICENSE" }
end
