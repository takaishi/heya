module Heya
  class CLI < Thor
    default_command :apply

    desc 'apply', ''
    option :dry_run, type: :boolean, default: false
    def apply
      manager = Heya::Manager.new
      manager.read
      manager.apply(options[:'dry_run'])
    end
  end
end