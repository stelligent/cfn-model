require 'spec_helper'
require 'cfn-model/model/references'

describe References do
  describe '#is_security_group_id_external' do
    context 'security group is external' do
      it 'returns true' do
        import_value = {
          'Fn::ImportValue' => 'someValue'
        }
        expected_value = true
        actual_value = References.is_security_group_id_external import_value
        expect(actual_value).to eq expected_value
      end
    end

    context 'security group is internal' do
      it 'returns false' do
        ref_function = {
          'Ref' => 'someResourceId'
        }
        expected_value = false
        actual_value = References.is_security_group_id_external ref_function
        expect(actual_value).to eq expected_value
      end
    end
  end

  describe '#resolve_security_group_id' do
    context 'an ImportValue GroupId' do
      it 'returns nil' do
        import_value = {
          'Fn::ImportValue' => 'someValue'
        }
        expected_value = nil
        actual_value = References.resolve_security_group_id import_value
        expect(actual_value).to eq expected_value
      end
    end

    context 'a Ref function referring to someResourceId' do
      it 'returns someResourceId' do
        ref_function = {
          'Ref' => 'someResourceId'
        }
        expected_value = 'someResourceId'
        actual_value = References.resolve_security_group_id ref_function
        expect(actual_value).to eq expected_value
      end
    end

    context 'a GetAtt function referring to [someResourceId2,GroupId]' do
      it 'returns someResourceId2' do
        get_att_function = {
          'Fn::GetAtt' => %w(someResourceId2 GroupId)
        }
        expected_value = 'someResourceId2'
        actual_value = References.resolve_security_group_id get_att_function
        expect(actual_value).to eq expected_value
      end
    end

    context 'a GetAtt function referring to [someResourceId2,someAtt]' do
      it 'returns nil' do
        get_att_function = {
          'Fn::GetAtt' => %w(someResourceId2 someAtt)
        }
        expected_value = nil
        actual_value = References.resolve_security_group_id get_att_function
        expect(actual_value).to eq expected_value
      end
    end

    context 'a GetAtt function referring to someResourceId3.someAtt' do
      it 'returns someResourceId3' do
        get_att_function = {
          'Fn::GetAtt' => 'someResourceId3.someAtt'
        }
        expected_value = nil
        actual_value = References.resolve_security_group_id get_att_function
        expect(actual_value).to eq expected_value
      end
    end

    context 'a GetAtt function referring to someResourceId3.GroupId' do
      it 'returns someResourceId3' do
        get_att_function = {
          'Fn::GetAtt' => 'someResourceId3.GroupId'
        }
        expected_value = 'someResourceId3'
        actual_value = References.resolve_security_group_id get_att_function
        expect(actual_value).to eq expected_value
      end
    end
  end
end
