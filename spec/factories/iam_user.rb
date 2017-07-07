require 'model/iam_user'

def iam_user_with_no_groups
  AWS::IAM::User.new
end

def iam_user_with_two_groups
  iam_user = AWS::IAM::User.new
  %w(group1 group2).each do |group_name|
    iam_user.groups << group_name
  end
  iam_user
end

def iam_user_with_four_groups
  iam_user = AWS::IAM::User.new
  ['groupA', 'groupB', {'Ref' => 'group1'}, {'Ref' => 'group2'}].each do |group_name|
    iam_user.groups << group_name
  end
  iam_user
end

