Project.configure do |project|
  project.build_command = './ci_build.sh'
  project.email_notifier.emails = ['kevinloken@me.com']
  
  # Set email from field
  project.email_notifier.from = 'kevinloken@me.com'
end
