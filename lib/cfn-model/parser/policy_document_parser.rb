require 'cfn-model/model/iam_policy'
require 'cfn-model/model/policy_document'

class PolicyDocumentParser
  def parse(raw_policy_document)
    policy_document = PolicyDocument.new

    policy_document.version = raw_policy_document['Version']

    policy_document.statements = streamline_array(raw_policy_document['Statement']) do |statement|
      parse_statement statement
    end

    policy_document
  end

  private

  def parse_statement(raw_statement)
    statement = Statement.new
    statement.effect = raw_statement['Effect']
    statement.sid = raw_statement['Sid']
    statement.condition = raw_statement['Condition']
    statement.actions = streamline_array(raw_statement['Action'])
    statement.not_actions = streamline_array(raw_statement['NotAction'])
    statement.resources = streamline_array(raw_statement['Resource'])
    statement.not_resources = streamline_array(raw_statement['NotResource'])
    statement.principal = raw_statement['Principal']
    statement.not_principal = raw_statement['NotPrincipal']
    statement
  end

  def streamline_array(one_or_more)
    return [] if one_or_more.nil?

    if one_or_more.is_a?(String) || one_or_more.is_a?(Hash)
      [block_given? ? yield(one_or_more) : one_or_more]
    elsif one_or_more.is_a? Array
      one_or_more.map { |one| block_given? ? yield(one) : one }
    else
      raise "unexpected object in streamline_array: #{one_or_more} #{one_or_more.class}"
    end
  end
end
