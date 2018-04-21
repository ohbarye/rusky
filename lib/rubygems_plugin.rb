# frozen_string_literal: true

require "rubygems"
require "rusky"

Gem.post_install do |installer|
  Rusky.install
end

Gem.pre_uninstall do |uninstaller|
  Rusky.uninstall
end
