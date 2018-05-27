module Heya
  class CLI < Thor
    default_command :apply

    desc 'apply', ''
    def apply
      manager = Heya::Manager.new
      manager.read
      manager.apply
    end
  end
end