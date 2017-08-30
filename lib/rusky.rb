require "rusky/version"
require "rusky/callback"

module Rusky
  def self.install
    Rusky::Callback.install
  end

  def self.uninstall
    Rusky::Callback.uninstall
  end
end
