Gem.pre_install do |installer|
  require "rusky"
  Rusky.install
end

Gem.pre_uninstall do |uninstaller|
  require "rusky"
  Rusky.uninstall
end
