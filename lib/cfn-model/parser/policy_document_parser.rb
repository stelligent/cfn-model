# frozen_string_literal: true

require 'cfn-model/model/iam_policy'
require 'cfn-model/model/references'

require 'cfn-model/model/policy_document'

class PolicyDocumentParser
  def parse(cfn_model, raw_policy_document)
    policy_document = PolicyDocument.new

    policy_document.version = References.resolve_value(cfn_model, raw_policy_document['Version'])

    policy_document.statements = streamline_array(raw_policy_document['Statement']) do |statement|
      parse_statement cfn_model, statement
    end

    policy_document
  end

  private

  def parse_statement(cfn_model, raw_statement)
    statement = Statement.new
    statement.effect = References.resolve_value(cfn_model, raw_statement['Effect'])
    statement.sid = References.resolve_value(cfn_model, raw_statement['Sid'])
    statement.condition = References.resolve_value(cfn_model, raw_statement['Condition'])
    statement.actions = References.resolve_value(cfn_model, streamline_array(raw_statement['Action']))
    statement.not_actions = References.resolve_value(cfn_model, streamline_array(raw_statement['NotAction']))
    statement.resources = References.resolve_value(cfn_model, streamline_array(raw_statement['Resource']))
    statement.not_resources = References.resolve_value(cfn_model, streamline_array(raw_statement['NotResource']))
    statement.principal = References.resolve_value(cfn_model, raw_statement['Principal'])
    statement.not_principal = References.resolve_value(cfn_model, raw_statement['NotPrincipal'])
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
