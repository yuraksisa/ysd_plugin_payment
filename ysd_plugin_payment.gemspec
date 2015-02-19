Gem::Specification.new do |s|
  s.name    = "ysd_plugin_payment"
  s.version = "0.1.40"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2012-05-16"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb','views/**/*.erb','i18n/**/*.yml','static/**/*.*'] 
  s.description = "Payment integration"
  s.summary = "Payment integration"
  
  s.add_runtime_dependency "json"
  
  s.add_runtime_dependency "ysd_md_payment"   # Model 
  s.add_runtime_dependency "ysd_md_configuration"
  
  s.add_runtime_dependency "ysd_plugin_auth"

  s.add_runtime_dependency "ysd_yito_core"    # Page loading
  s.add_runtime_dependency "ysd_yito_js"      # Yito JS library

  s.add_runtime_dependency "ysd_core_plugins" # Plugins system

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rack"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "sinatra-r18n"
  s.add_development_dependency "dm-sqlite-adapter" # Model testing using sqlite  
  s.add_development_dependency "ysd_core_themes"
  
end