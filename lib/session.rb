module Synchro
  class ProjectSession
    attr_reader :remote, :local 
    
    def initialize(local, remote)
      @local = local
      @remote = remote
    end
  end


end
