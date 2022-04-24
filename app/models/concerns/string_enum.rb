module StringEnum
  extend ActiveSupport::Concern

  module ClassMethods
    # ActiveRecord enum has undocumented support for enums with string rather than integer representations.
    # To enable it you have to define an enum like so:
    #
    #   enum field: { value1: 'value1', value2: 'value2' }
    #
    # which is rather redundant. This is a shortcut which lets you define it as follows:
    #
    #   string_enum field: [ :value1, :value2 ]
    #
    def string_enum(definitions)
      field = definitions.keys[0]
      values = definitions.values[0]

      # We want to transform the array of values into a hash, which is most easily done by
      # creating an array of arrays of [ key, value ], then calling to_h on it.
      definitions[field] = values.index_with(&:to_s)

      # Define the enum using Rails' built-in enum method
      enum(**definitions)

      # We need this to be a string for the rest of the steps anyway
      field = field.to_s

      # Redefine class method 'fields' to return the original array of values rather than the hash we transformed it to
      singleton_class.send(:define_method, field.pluralize) { values }

      # Validate presence if the database field doesn't allow nulls
      return if columns_hash[field]&.null

      validates field, presence: true
    end
  end
end
