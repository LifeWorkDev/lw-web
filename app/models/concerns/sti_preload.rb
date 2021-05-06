module STIPreload
  extend ActiveSupport::Concern

  unless Rails.application.config.eager_load
    included do
      cattr_accessor :preloaded, instance_accessor: false
    end

    class_methods do
      def descendants
        preload_sti unless preloaded
        super
      end

      def subclasses
        preload_sti unless preloaded
        super
      end

      def preload_sti
        self.preloaded = true
        Dir[const_get(:SUBCLASS_FILES)].each { |f| f.delete_prefix("app/models/").delete_suffix(".rb").camelize.constantize }
      end
    end
  end
end
