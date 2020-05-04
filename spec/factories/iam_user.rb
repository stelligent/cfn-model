require 'cfn-model/model/iam_user'

def iam_user_with_no_groups(cfn_model: CfnModel.new)
  AWS::IAM::User.new cfn_model
end

def iam_user_with_two_groups(cfn_model: CfnModel.new)
  iam_user = AWS::IAM::User.new cfn_model
  %w(group1 group2).each do |group_name|
    iam_user.groups += [group_name]
    iam_user.group_names += [group_name]
  end
  iam_user
end

def iam_user_with_two_groups_and_two_additions(cfn_model: CfnModel.new)
  iam_user = AWS::IAM::User.new cfn_model

  %w(groupA groupB).each do |group_name|
    iam_user.groups += [group_name]
  end

  ['groupA', 'groupB', {'Ref' => 'group1'}, 'groupC'].each do |group_name|
    iam_user.group_names +=  [group_name]
  end

  iam_user
end

def iam_user_with_one_addition(cfn_model: CfnModel.new)
  iam_user = AWS::IAM::User.new cfn_model
  iam_user.userName = 'jimbob'
  ['groupA'].each do |group_name|
    iam_user.group_names += [group_name]
  end
  iam_user
end
