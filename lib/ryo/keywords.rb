# frozen_string_literal: true

##
# The {Ryo::Keywords Ryo::Keywords} module implements Ryo equivalents
# to some of JavaScript's keywords - for example: the **in** and **delete**
# operators. The instance methods of this module are available as singleton
# methods on the {Ryo} module.
module Ryo::Keywords
  extend self

  ##
  # @example
  #   person = Ryo(greet: Ryo.fn { |name| puts "Hello #{name}" })
  #   person.greet.("tim")
  #
  # @param [Proc] b
  #  The function's body.
  #
  # @return [Ryo::Function]
  #  Returns a Ryo function.
  #
  # @see Ryo::Function Ryo::Function
  def fn(&b)
    Ryo::Function.new(&b)
  end
  alias_method :function, :fn

  # Equivalent to JavaScript's **in** operator.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @param [String] property
  #  The property name.
  #
  # @return [Boolean]
  #  Returns true when **property** is a member of **ryo**, or
  #  its prototype chain.
  def in?(ryo, property)
    Ryo::Reflect.property?(ryo, property) ||
      Ryo::Reflect.property?(Ryo::Reflect.prototype_of(ryo), property)
  end

  ##
  # More or less equivalent to JavaScript's **delete** operator.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @param [String] property
  #  The property to delete.
  #
  # @return [::Object, ::BasicObject]
  #  Returns the value of the deleted property.
  def delete(ryo, property)
    property = property.to_s
    if Ryo::Reflect.property?(ryo, property)
      Ryo::Reflect.table_of(ryo).delete(property)
    else
      return if Ryo::Reflect.getter_defined?(ryo, property)
      Ryo::Reflect.define_method!(ryo, property) { ryo[property] }
    end
  end
end
