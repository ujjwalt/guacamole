# -*- encoding : utf-8 -*-

require 'active_support'
require 'active_support/concern'
require 'active_model' # Cherry Pick not possible

module Guacamole
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :create, :validate
    end

    class NoopCallback
      include Guacamole::Callbacks
    end

    class CallbackChain
      def initialize(model, *callbacks)
        @callbacks = callbacks.flatten.compact
        @model     = model
      end

      def run_callbacks(kind, &block)
        @callbacks.each do |cb|
          cb.new(@model).run_callbacks kind, &block
        end
      end
    end

    class << self
      def register_callback(model_class, callback_class)
        registry[model_class] ||= []
        registry[model_class] << callback_class
      end

      def callbacks_for(model)
        CallbackChain.new(model, default_callbacks, registry[model.class])
      end

      def registry
        @registry ||= {}
      end

      def default_callbacks
        [NoopCallback]
      end
    end

    module ClassMethods
      def around(model_class_name)
        model_class = model_class_name.to_s.camelcase.constantize
        Callbacks.register_callback model_class, self
      end
    end

    def initialize(model_instance)
      @object = model_instance
    end

    def object
      @object
    end
  end
end
