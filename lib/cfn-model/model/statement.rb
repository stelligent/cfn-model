require_relative 'principal'

class Statement
  attr_accessor :sid, :effect, :condition
  attr_accessor :actions, :not_actions
  attr_accessor :resources, :not_resources
  attr_accessor :principal, :not_principal

  def initialize
    @actions = []
    @not_actions = []
    @resources = []
    @not_resources = []
  end

  def wildcard_actions
    @actions.select { |action| action.to_s =~ /\*/ }
  end

  def wildcard_principal?
    Principal.wildcard? @principal
  end

  def wildcard_resources
    @resources.select { |action| action.to_s =~ /\*/ }
  end

  def ==(another_statement)
    @effect == another_statement.effect &&
      @actions == another_statement.actions &&
      @not_actions == another_statement.not_actions &&
      @resources == another_statement.resources &&
      @not_resources == another_statement.not_resources &&
      @principal == another_statement.principal &&
      @not_principal == another_statement.not_principal &&
      @condition == another_statement.condition
  end
end
