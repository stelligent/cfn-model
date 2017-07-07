
class IamUserParser
  def parse(cfn_model:, resource:)
    iam_user = resource

    user_to_group_additions = cfn_model.resources_by_type 'AWS::IAM::UserToGroupAddition'
    user_to_group_additions.each do |user_to_group_addition|

      if user_to_group_addition_has_username(user_to_group_addition.users,iam_user)
        iam_user.groups << user_to_group_addition.groupName

        # we need to figure out the story on resolving Refs i think for this to be real
      end
    end
  end

  private

  def user_to_group_addition_has_username(addition_user_names, user_to_find)
    addition_user_names.each do |addition_user_name|
      if addition_user_name == user_to_find.userName
        return true
      end

      # what about other functions? - remember the YAML parser converts !Ref xx -> Ref:xxx
      if addition_user_name.is_a? Hash
        if !addition_user_name['Ref'].nil?
          if addition_user_name['Ref'] == user_to_find.logical_resource_id
            return true
          end
        end
      end
    end
    false
  end

  # def resolve_user_logical_resource_id(user)
  #   if not user['Ref'].nil?
  #     user['Ref']
  #   elsif not user['Fn::GetAtt'].nil?
  #     fail 'Arn not legal for user to group addition'
  #   else
  #     @dangler
  #   end
  # end

end
