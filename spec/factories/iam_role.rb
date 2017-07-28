require 'cfn-model/model/iam_role'

def iam_role_with_single_statement
  trust_statement = Statement.new
  trust_statement.effect = 'Allow'
  trust_statement.actions << 'sts:AssumeRole'
  trust_statement.principal = {
    'Service' => ['ec2.amazonaws.com'],
    'AWS' => 'arn:aws:iam::324320755747:root'
  }

  trust_policy = PolicyDocument.new
  trust_policy.version = '2012-10-17'
  trust_policy.statements << trust_statement

  statement = Statement.new
  statement.effect = 'Allow'
  statement.actions << '*'
  statement.resources << '*'

  policy_document = PolicyDocument.new
  policy_document.version = '2012-10-17'
  policy_document.statements << statement

  policy = Policy.new
  policy.policy_name = 'root'
  policy.policy_document = policy_document

  role = AWS::IAM::Role.new
  role.path = '/'
  role.assumeRolePolicyDocument = {
    'Version'=> '2012-10-17',
    'Statement'=> {
      'Effect' => 'Allow',
      'Principal' => {
        'Service' => ['ec2.amazonaws.com'],
        'AWS' => 'arn:aws:iam::324320755747:root'
      },
      'Action' => ['sts:AssumeRole']
    }
  }
  role.assume_role_policy_document = trust_policy
  role.policy_objects << policy
  role.policies << {
    'PolicyName' => 'root',
    'PolicyDocument' => {
      'Version' => '2012-10-17',
      'Statement' => {
        'Effect' => 'Allow',
        'Action' => '*',
        'Resource' => '*'
      }
    }
  }

  role
end
