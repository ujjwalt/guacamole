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

      before_create :add_create_timestamps
      before_update :update_updated_at_timestamp
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

    def initialize(model_instance)
      @object = model_instance
    end

    def object
      @object
    end

    def add_create_timestamps
      object.created_at = Time.now
      update_updated_at_timestamp
    end

    def update_updated_at_timestamp
      object.updated_at = Time.now
    end
  end
end
