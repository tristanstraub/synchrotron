module Synchro
  module Template
    class Namespace
      def initialize(hash)
        hash.each do |key, value|
          singleton_class.send(:define_method, key) { value }
        end 
      end

      def get_binding
        binding
      end
    end
  end
end

class String
  def erb(args)
    templateArgs = Synchro::Template::Namespace.new(args)
    ERB.new(self).result(templateArgs.get_binding)
  end
end
