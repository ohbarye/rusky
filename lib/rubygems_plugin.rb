require 'rusky'

Gem.post_install do |installer|
  Rusky.install
  puts installer.inspect
end

Gem.pre_uninstall do |uninstaller|
  Rusky.uninstall
  puts uninstaller.inspect
end
