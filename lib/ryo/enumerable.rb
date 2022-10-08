# frozen_string_literal: true

##
# The {Ryo::Enumerable Ryo::Enumerable} module implements methods
# for iterating through and performing operations on Ryo objects.
# The methods implemented by this module are available as singleton
# methods on the {Ryo} module.
module Ryo::Enumerable
  include Ryo::Keywords
  include Ryo::Reflect

  ##
  # The {#each} methods iterates a Ryo object, and yields a key / value pair.
  # When a block is not given, {#each} returns an Enumerator.
  #
  # @example
  #  point_a = Ryo(x: 1, y: 2)
  #  point_b = Ryo(y: 1)
  #  Ryo.each(point_b) { p [_1, _2] }
  #  # ["y", 1]
  #  # ["y", 2]
  #  # ["x", 1]
  #
  # @param [Ryo::Object, Ryo::BasicObject] ryo
  #  A Ryo object.
  #
  # @param depth (see #each_ryo)
  #
  # @return [<Enumerator, Array>]
  #  Returns an Enumerator when a block is not given, otherwise returns an Array.
  def each(ryo, depth: nil)
    return enum_for(:each, ryo) unless block_given?
    each_ryo(ryo, depth: depth) do |_, key, value|
      yield(key, value)
    end
  end

  ##
  # The {#each_ryo} method iterates through a Ryo object, and its prototypes.
  # {#each_ryo} yields three parameters: a Ryo object, a key, and a value.
  #
  # @example
  #  point_a = Ryo(x: 1, y: 2)
  #  point_b = Ryo({y: 3}, point_a)
  #  Ryo.each_ryo(point_b) { |ryo, key, value| p [ryo, key, value] }
  #  # [point_b, "y", 3]
  #  # [point_a, "x", 1]
  #  # [point_a, "y", 2]
  #
  # @param [<Ryo::BasicObject, Ryo::Object>] ryo
  #  A Ryo object.
  #
  # @param [Integer] depth
  #  The `depth` parameter can be used to control how far down the prototype chain a
  #  [`Ryo::Enumerable`](https://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html) method
  #  should go. A depth of 0 covers a Ryo object, and none of its prototypes. A depth
  #  of 1 covers a Ryo object, and one prototype - and so on. By default the entire
  #  prototype chain is iterated through.
  #
  # @return [<Ryo::BasicObject, Ryo::Object>]
  def each_ryo(ryo, depth: nil)
    proto_chain = [ryo, *prototype_chain_of(ryo)]
    depth ||= -1
    proto_chain[0..depth].each do |ryo|
      properties_of(ryo).each do |key|
        yield(ryo, key, ryo[key])
      end
    end
    ryo
  end

  ##
  # The {#map} method creates a copy of a Ryo object, and then performs a map operation
  # on the copy and its prototypes.
  #
  # @param (see #map!)
  # @return (see #map!)
  def map(ryo, depth: nil, &b)
    map!(Ryo.dup(ryo), depth: depth, &b)
  end

  ##
  # The {#map!} method performs an in-place map operation on a Ryo object, and its prototypes.
  #
  # @example
  #  point = Ryo(x: 2, y: 4)
  #  Ryo.map!(point) { _2 * 2 }
  #  [point.x, point.y]
  #  # => [4, 8]
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param depth (see #each_ryo)
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  def map!(ryo, depth: nil)
    each_ryo(ryo, depth: depth) do |ryo, key, value|
      ryo[key] = yield(key, value)
    end
  end

  ##
  # The {#select} method creates a copy of a Ryo object, and then performs a filter operation
  # on the copy and its prototypes.
  #
  # @param (see #select!)
  # @return (see #select!)
  def select(ryo,  depth: nil, &b)
    select!(Ryo.dup(ryo), depth: depth, &b)
  end

  ##
  # The {#select!} method performs an in-place filter operation on a Ryo object, and
  # its prototypes.
  #
  # @example
  #  point_a = Ryo(x: 1, y: 2, z: 3)
  #  point_b = Ryo({z: 4}, point_a)
  #  Ryo.select!(point_b) { |key, value| %w(x y).include?(key) }
  #  [point_b.x, point_b.y, point_b.z]
  #  # => [1, 2, nil]
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param depth (see #each_ryo)
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  def select!(ryo, depth: nil)
    each_ryo(ryo, depth: depth) do |ryo, key, value|
      delete(ryo, key) unless yield(key, value)
    end
  end

  ##
  # The {#reject} method creates a copy of a Ryo object, and then performs a filter operation
  # on the copy and its prototypes.
  #
  # @param (see #reject!)
  # @return (see #reject!)
  def reject(ryo, depth: nil, &b)
    reject!(Ryo.dup(ryo), depth: depth, &b)
  end

  ##
  # The {#reject!} method performs an in-place filter operation on a Ryo object, and
  # its prototypes.
  #
  # @example
  #  point_a = Ryo(x: 1, y: 2, z: 3)
  #  point_b = Ryo({z: 4}, point_a)
  #  Ryo.reject!(point_b) { |key, value| value > 2 }
  #  [point_b.x, point_b.y, point_b.z]
  #  # => [1, 2, nil]
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param depth (see #each_ryo)
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  def reject!(ryo, depth: nil)
    each_ryo(ryo, depth: depth) do |ryo, key, value|
      delete(ryo, key) if yield(key, value)
    end
  end

  ##
  # The {#any?} method iterates through a Ryo object, and its prototypes - yielding a
  # key / value pair to a block. If the block ever returns a truthy value, {#any?} will
  # break from the iteration and return true - otherwise false will be returned.
  #
  # @param depth (see #each_ryo)
  # @return [Boolean]
  def any?(ryo, depth: nil)
    each_ryo(ryo, depth: depth) do |_, key, value|
      return true if yield(key, value)
    end
    false
  end

  ##
  # The {#all?} method iterates through a Ryo object, and its prototypes - yielding a
  # key / value pair to a block. If the block ever returns a falsey value, {#all?} will
  # break from the iteration and return false - otherwise true will be returned.
  #
  # @param depth (see #each_ryo)
  # @return [Boolean]
  def all?(ryo, depth: nil)
    each_ryo(ryo, depth: depth) do |_, key, value|
      return false unless yield(key, value)
    end
    true
  end

  ##
  # The {#find} method iterates through a Ryo object, and its prototypes - yielding a
  # key / value pair to a block. If the block ever returns a truthy value, {#find} will
  # break from the iteration and return a Ryo object - otherwise nil will be returned.
  #
  # @example
  #  point_a = Ryo(x: 5)
  #  point_b = Ryo({y: 10}, point_a)
  #  point_c = Ryo({z: 15}, point_b)
  #  ryo = Ryo.find(point_c) { |key, value| value == 5 }
  #  ryo == point_a # => true
  #
  # @param depth (see #each_ryo)
  # @return [<Ryo::Object, Ryo::BasicObject>, nil]
  def find(ryo, depth: nil)
    each_ryo(ryo, depth: depth) do |ryo, key, value|
      return ryo if yield(key, value)
    end
    nil
  end
end
