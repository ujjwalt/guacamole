# -*- encoding : utf-8 -*-

require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/string/inflections'
require 'active_model' # Cherry Pick not possible

module Guacamole
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :validate, :save, :create, :update, :destroy
    end

    class DefaultCallback
      include Guacamole::Callbacks
    end

    class << self
      def register_callback(model_class, callback_class)
        registry[model_class] = callback_class
      end

      def callbacks_for(model)
        registry[model.class].new(model)
      end

      def registry
        @registry ||= Hash.new(DefaultCallback)
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
