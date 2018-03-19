require 'cfn-model/model/iam_policy'
require 'cfn-model/model/cfn_model'

def valid_iam_policy(cfn_model: CfnModel.new)
  statement = Statement.new
  statement.effect = 'Allow'
  statement.actions << '*'
  statement.resources << '*'

  policy_document = PolicyDocument.new
  policy_document.version = '2012-10-17'
  policy_document.statements << statement


  role = AWS::IAM::Policy.new cfn_model
  role.policyName = 'wilma'
  role.policyDocument = {
    'Version'=> '2012-10-17',
    'Statement'=> {
      'Effect' => 'Allow',
      'Action' => '*',
      'Resource' => '*'
    }
  }
  role.policy_document = policy_document
  role.groups = %w(fredGroup)
  role
end

