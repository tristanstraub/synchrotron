module Synchro
  libdir = File.join(File.dirname(__FILE__), 'lib')
  $LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

  require 'config'
  require 'methods'
  require 'shoes'

  require 'erb'
  require 'ostruct'
  require 'logger'

  @logger = Logger.new(STDOUT)
  def self.logger
    @logger
  end

  config = Synchro::Config::SynchroConfig.new 'config.yaml'
  
  hostname = `hostname`.strip()
  local = config.machines[hostname]

  config.machines.each do |remoteName, remote|
    if remote.hostname != local.hostname
      Synchro.logger.info "Synchronising from host '#{remote.hostname}'"
      local.projects.each do |projectName, project|
        if project.type == :git
          syncMethod = Synchro::Methods::Git.new projectName, local, remote
          syncMethod.execute(dry_run: false)
        end
      end
    end
  end  
end
