# -*- encoding : utf-8 -*-

module Guacamole
  # Build an AQL query for ArangoDB
  class AqlQuery < Query
    # The AQL fragment to be added into the complete query
    attr_accessor :aql_fragment

    # The associated collection
    attr_reader :collection

    # Create a new AqlQuery
    #
    # @param [Guacamole::Collection] collection The collection class to be used
    # @param [Class] mapper the class of the mapper to use
    def initialize(collection, mapper)
      @collection = collection
      super(collection.connection.query, mapper)
    end

    # Set the bind parameters
    #
    # @param [Hash] bind_parameters All the bind parameters
    def bind_parameters=(bind_parameters)
      @options[:bind_vars] = bind_parameters
    end

    # Get the bind parameters
    #
    # @return [Hash] All the bind parameters
    def bind_parameters
      @options[:bind_vars]
    end

    # Creates an AQL string based on the `aql_fragment`,
    # the collection and model information.
    #
    # @return [String] An AQL string ready to be send to Arango
    def aql_string
      aql_string = "FOR #{model_name} IN #{collection_name} #{aql_fragment} RETURN #{model_name}"
      Guacamole.logger.debug "[AQL] #{aql_string} | bind_parameters: #{bind_parameters}"
      aql_string
    end

    private

    # The name of the model to be used in the query
    def model_name
      mapper.model_class.model_name.element
    end

    # The name of the collection to be used in the query
    def collection_name
      collection.collection_name
    end

    # Executes an AQL query with bind parameters
    #
    # @see Query#perfom_query
    def perfom_query(iterator)
      connection.execute(aql_string, options).each(&iterator)
    end
  end
end
