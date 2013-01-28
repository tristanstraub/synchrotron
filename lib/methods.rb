module Synchro
  module Methods
    class Git
      attr_reader :local, :remote, :projectName
      
      def initialize(projectName, local, remote)
        @projectName = projectName
        @local = local
        @remote = remote
      end

      def localProject
        local.projects[@projectName]
      end

      def remoteProject 
        remote.projects[@projectName]
      end

      def dry_run
        self.execute(dry_run: true)
      end

      def system(command, options = {})
        raise "Must supply dry_run" unless options.has_key? :dry_run
        dry_run = options[:dry_run]

        Synchro.logger.info "Executing: #{command}"
        Kernel.system(command) unless dry_run
      end

      def execute(options = {})
        raise "Must supply dry_run" unless options.has_key? :dry_run
        dry_run = options[:dry_run]

        Synchro.logger.info "Synchronising project '#{projectName}', using method '#{localProject.type}'"

        Synchro.logger.info "Git synchronize dry_run: #{dry_run}, project: '#{projectName}', local: '#{local.name}', remote: #{remote.name}"
        Synchro.logger.debug "Method: #{inspect}"

        dir = self.localProject.location
        localGitRepo = "#{self.localProject.location}/.git"
        git = "git"

        gitCommand = nil
        strippedRemoteLocation = remoteProject.location.gsub(/^\//, '')
        remoteGitRepo = "ssh://#{remote.hostname}/#{strippedRemoteLocation}"

        if !(File.directory? (File.join self.localProject.location, ".git"))
          Synchro.logger.debug "Local git repo doesn't exist '#{localGitRepo}' exists"
          Synchro.logger.info "Cloning git repo: #{remoteGitRepo}"

          gitCommand = "clone"

          gitCloneCommand = "#{git} #{gitCommand} \"#{remoteGitRepo}\" \"#{self.localProject.location}\"" 
          self.system(gitCloneCommand, dry_run: dry_run)
        else
          Synchro.logger.debug "Local git repo '#{localGitRepo}' exists"
          Synchro.logger.info "Fetching git repo '#{remoteGitRepo}'"

          gitCommand = "fetch"

          gitFetchCommand = "#{git} --git-dir=\"#{localGitRepo}\" #{gitCommand} \"#{remoteGitRepo}\""
          self.system(gitFetchCommand, dry_run: dry_run)
        end
      end
    end
  end
end
