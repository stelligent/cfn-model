require 'cfn-model/model/iam_policy'

def valid_iam_policy
  statement = Statement.new
  statement.effect = 'Allow'
  statement.actions << '*'
  statement.resources << '*'

  policy_document = PolicyDocument.new
  policy_document.version = '2012-10-17'
  policy_document.statements << statement


  role = AWS::IAM::Policy.new
  role.policyName = 'wilma'
  role.policyDocument = policy_document
  role.groups = %w(fredGroup)
  role
end

