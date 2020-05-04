require 'cfn-model/model/kms_key'

def kms_key_with_single_statement(cfn_model: CfnModel.new)
  statement = Statement.new
  statement.effect = 'Allow'
  statement.actions += ['kms:*']
  statement.resources += ['*']
  statement.principal = {
    'AWS' => 'arn:aws:iam::123456789012:user/Test'
  }

  policy_document = PolicyDocument.new
  policy_document.version = '2012-10-17'
  policy_document.statements << statement

  policy = Policy.new
  policy.policy_document = policy_document

  key = AWS::KMS::Key.new cfn_model
  key.key_policy = policy
  key.keyPolicy = {
    "Version"=>"2012-10-17",
    "Statement"=>{
      "Effect"=>"Allow",
      "Action"=>"kms:*",
      "Principal"=>{"AWS"=>"arn:aws:iam::123456789012:user/Test"},
      "Resource"=>"*"}}
  key.raw_model = {
    "AWSTemplateFormatVersion"=>"2010-09-09",
    "Resources"=>{
      "RootKey"=>{
        "Type"=>"AWS::KMS::Key",
        "Properties"=>{
          "KeyPolicy"=>key.keyPolicy}}}}

  key
end
