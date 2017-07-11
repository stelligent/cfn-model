require_relative 'statement'

class PolicyDocument
  attr_accessor :version, :statements

  def initialize
    @statements = []
  end

  def wildcard_allowed_resources
    @statements.select { |statement| !statement.wildcard_resources.empty? && statement.effect == 'Allow' }
  end

  def wildcard_allowed_actions
    @statements.select { |statement| !statement.wildcard_actions.empty? && statement.effect == 'Allow' }
  end

  def wildcard_allowed_principals
    @statements.select { |statement| statement.wildcard_principal? && statement.effect == 'Allow' }
  end

  ##
  # Select any Statement objects that Allow in conjunction with a NotAction
  #
  def allows_not_action
    @statements.select { |statement| !statement.not_actions.empty? && statement.effect == 'Allow' }
  end

  def allows_not_resource
    @statements.select { |statement| !statement.not_resources.empty? && statement.effect == 'Allow' }
  end

  def allows_not_principal
    @statements.select { |statement| !statement.not_principal.nil? && statement.effect == 'Allow' }
  end

  def ==(another_doc)
    @version == another_doc.version && @statements == another_doc.statements
  end

  def to_s
    <<END
{
  version=#{@version}
  statements=#{@statements}
}
END
  end
end



