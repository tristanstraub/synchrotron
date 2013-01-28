module Synchro
  module Config
    require 'yaml'

    class Machine
      attr_accessor :name
      attr_reader :projects

      def hostname
        self.name
      end

      def initialize(config, node)
        @projects = {}
        @name = node['name']

        node['projects'].each do |node|
          project = Project.new config, node
          @projects[project.name] = project
        end
      end
    end

    class CoreProject
      attr_reader :name, :type, :location

      def initialize(config, node)
        @config = config

        @name = node['name']
        if node['type']
          @type = node['type'].intern
        end
        @location = node['location']
      end
    end

    class Project < CoreProject
      def initialize(config, node)
        super(config, node)

        globalProject = config.projects[node['name']]
        raise "No Global Project: #{node['name']}" if not globalProject

        @name ||= globalProject.name
        @type ||= globalProject.type.intern
        @location ||= globalProject.location
      end
    end

    class SynchroConfig
      attr_reader :machines, :projects

      def initialize(filename)
        yaml = YAML.load_file(filename)

        @projects = {}
        yaml['projects'].each do |node|
          project = CoreProject.new self, node
          @projects[project.name] = project
        end

        @machines = {}
        yaml['machines'].each do |node|
          machine = Machine.new self, node
          @machines[machine.name] = machine
        end
      end
    end
  end
end
