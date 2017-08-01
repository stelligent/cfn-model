require 'cfn-model/model/iam_group'
require 'cfn-model/model/policy'
require 'cfn-model/model/policy_document'
require 'cfn-model/model/statement'

def iam_group_with_no_policies
  AWS::IAM::Group.new
end

def iam_group_with_policies
  expected_group = AWS::IAM::Group.new

  expected_group.policies << {
    'PolicyDocument' => {
      'Statement' => {
        'Effect' => 'Allow',
        'Action' => '*',
        'Resource' => '*'
      }
    },
    'PolicyName' => 'jimbob'
  }

  policy = Policy.new
  policy.policy_name = 'jimbob'

  statement = Statement.new
  statement.effect = 'Allow'
  statement.actions << '*'
  statement.resources << '*'

  policy_document = PolicyDocument.new
  policy_document.statements << statement

  policy.policy_document = policy_document
  expected_group.policy_objects << policy
  expected_group
end