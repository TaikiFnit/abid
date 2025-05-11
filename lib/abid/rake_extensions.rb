# Delegate Rake.application to Abid.global.application
# Ruby 3.4対応: メソッドの再定義を避ける
unless Rake.singleton_methods.include?(:abid_original_application)
  class << Rake
    alias_method :abid_original_application, :application
    alias_method :abid_original_application=, :application=
    
    def application
      Abid.global.application
    end

    def application=(app)
      Abid.global.application = app
    end
  end
end

module Rake
  class Task
    def bind(params = {})
      Abid::DSL::RakeJob.new(self, params)
    end

    def params_spec
      {}
    end
  end
end
