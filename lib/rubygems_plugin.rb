require 'rusky'

Gem.post_install do |installer|
  Rusky::Callback.install
  puts installer.inspect
end

Gem.pre_uninstall do |uninstaller|
  Rusky::Callback.uninstall
  puts uninstaller.inspect
end
