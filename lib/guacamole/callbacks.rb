# -*- encoding : utf-8 -*-

require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/string/inflections'
require 'active_model' # Cherry Pick not possible

module Guacamole
  # Define callbacks for different life cycle events of a model
  #
  # Callbacks in Guacamole are defined in dedicated classes only. There will be no interface to implement them
  # in the model or the collection context. This was done due to the nature of the data mapper pattern:
  #
  #  * The model doesn't know anything about the database thus defining persistence related callbacks (i.e. `before_create`)
  #    would weaken this separation.
  #  * Validation happens in the context of the model and thus defining all callbacks in the collection would still
  #    be somewhat awkward.
  #
  # Due to those reasons Guacamole employs the concept of **external callbacks**. Just define a class and include
  # the `Guacamole::Callbacks` module and you can define all kinds of callbacks. Under the hood `ActiveModel::Callbacks`
  # is used to provide the callback execution functionality.
  #
  # @note Wether you define a callback class for your model or not, internally there always will be a callback.
  #
  # Since maintaining the time stamp attributes of your models are implemented as callbacks as well your callback
  # class will have those methods included.
  #
  # Binding a callback class to a model will happen in the `Model.callbacks` method.
  #
  # Each callback class will be instantiated with the appropriate model instance. That instance is accessible through
  # the `object` method.
  #
  # @example Define a callback to hash the password prior creation
  #   class UserCallbacks
  #     include Guacamole::Callbacks
  #
  #     before_create :encrypt_password
  #
  #     def encrypt_password
  #       object.encrypted_password = BCrypt::Password.create(object.password)
  #     end
  #   end
  #
  # @!method self.before_validate(method_name)
  #   Registers a method to be run before the validation will happen
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.around_validate(method_name)
  #   Registers a method to be run before and after the validation will happen.
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #   @note You must `yield` at some point in the method.
  #
  # @!method self.after_validate(method_name)
  #   Registers a method to be run after the validation happened
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.before_save(method_name)
  #   Registers a method to be run before the collection class saves the model
  #
  #   Saving a model will always happen, no matter if the model will be created or
  #   updated.
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.around_save(method_name)
  #   Registers a method to be run before and after saving the model
  #
  #   Saving a model will always happen, no matter if the model will be created or
  #   updated.
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #   @note You must `yield` at some point in the method.
  #
  # @!method self.after_save(method_name)
  #   Registers a method to be run after the collection class has saved the model
  #
  #   Saving a model will always happen, no matter if the model will be created or
  #   updated.
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.before_create(method_name)
  #   Registers a method to be run before initially creating the model in the database
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.around_create(method_name)
  #   Registers a method to be run before and after creating the model
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #   @note You must `yield` at some point in the method.
  #
  # @!method self.after_create(method_name)
  #   Registers a method to be run after the creation of the model
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.before_update(method_name)
  #   Registers a method to be run before updating the model
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.around_update(method_name)
  #   Registers a method to be run before and after updating the model
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #   @note You must `yield` at some point in the method.
  #
  # @!method self.after_update(method_name)
  #   Registers a method to be run after the model has been updated
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.before_destroy(method_name)
  #   Registers a method to be run before deleting the model
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #
  # @!method self.around_destroy(method_name)
  #   Registers a method to be run before and after the deletion
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  #   @note You must `yield` at some point in the method.
  #
  # @!method self.after_destroy(method_name)
  #   Registers a method to be run after the deletion of the model has happened
  #
  #   @param [Symbol] method_name The name of the method to be executed
  #   @api public
  module Callbacks
    extend ActiveSupport::Concern
    # @!parse extend ActiveModel:Callbacks

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :validate, :save, :create, :update, :destroy

      before_create :add_create_timestamps
      before_update :update_updated_at_timestamp
    end

    # The default callback to be used if no custom callback was defined. This is done because it simplifies
    # the callback invocation code and allows us to use callbacks for adding time stamps to the models.
    class DefaultCallback
      include Guacamole::Callbacks
    end

    # A proxy class around the callback class itself.
    #
    # The sole reason for its existence is to specify multiple callback runs at once. The alternative
    # would have been to nest the `run_callbacks` calls within the caller. It was decided to have bit
    # more complex proxy class to hide those details from the caller.
    #
    # @example
    #   callbacks = Callbacks.callbacks_for(model)
    #   callbacks.run_callbacks :save, :create do
    #     CakeCollection.create model
    #   end
    # @private
    class CallbackProxy
      attr_reader :callbacks

      # Create a new proxy with the original callbacks class as input
      #
      # @param [Callbacks] callbacks The original callback class to be executed
      def initialize(callbacks)
        @callbacks = callbacks
      end

      # Runs the given kinds of callbacks
      #
      # @param [Array<Symbol>] callbacks_to_run One or more kinds of callbacks to be run
      # @yield Will call the code block wrapped by the given callbacks
      def run_callbacks(*callbacks_to_run, &block)
        outer = callbacks_to_run.pop

        if callbacks_to_run.empty?
          @callbacks.run_callbacks(outer, &block)
        else
          @callbacks = run_callbacks(*callbacks_to_run) do
            @callbacks.run_callbacks(outer, &block)
          end
        end
      end
    end

    class << self
      # Register a callback class to be used with the model
      #
      # @api private
      # @param [Model] model_class The class of a model
      # @param [Callbacks] callback_class The class of the callbacks
      def register_callback(model_class, callback_class)
        registry[model_class] = callback_class
      end

      # Retrieve the callback instance for the given model
      #
      # @api private
      # @params [Model] model The model instance for which callbacks must be executed
      # @return [Callbacks] A callback instance with the given model accessible via `object`
      def callbacks_for(model)
        CallbackProxy.new registry[model.class].new(model)
      end

      # The internal storage of the callback-model pairs
      #
      # @api private
      # @return [Hash] A hash with the default set to the `DefaultCallback`
      def registry
        @registry ||= Hash.new(DefaultCallback)
      end
    end

    # Create a new callback instance with the given model instance
    #
    # @param [Model] model_instance The model instance the callbacks should be executed for
    def initialize(model_instance)
      @object = model_instance
    end

    # Provides access to the model instance.
    #
    # @retun [Model] A model instance
    # @api public
    def object
      @object
    end

    # Sets `created_at` and `updated_at` to `Time.now`
    def add_create_timestamps
      object.created_at = Time.now
      update_updated_at_timestamp
    end

    # Sets `updated_at` to `Time.now`
    def update_updated_at_timestamp
      object.updated_at = Time.now
    end
  end
end
