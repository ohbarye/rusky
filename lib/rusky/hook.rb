require "rusky"

Gem.pre_install do |installer|
  Rusky.install
end

Gem.pre_uninstall do |uninstaller|
  Rusky.uninstall
end
