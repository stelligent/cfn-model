require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/model/references'
require 'cfn-model/model/parameter'

_ = nil

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

  describe '#resolve_value' do
    context 'plain string' do
      it 'returns string' do
        actual_value = References.resolve_value(_, '0.0.0.0/0')
        expected_value = '0.0.0.0/0'

        expect(actual_value).to eq expected_value
      end
    end

    context 'array or random crud' do
      it 'returns array' do
        actual_value = References.resolve_value(_, %w(0.0.0.0/0))
        expected_value = %w(0.0.0.0/0)

        expect(actual_value).to eq expected_value
      end
    end

    context 'hash that is not a Ref' do
      it 'returns hash as-is' do
        get_att_hash = {
          'Fn::GetAtt' => 'someResourceId3.GroupId'
        }
        actual_value = References.resolve_value(_, get_att_hash)
        expected_value = get_att_hash

        expect(actual_value).to eq expected_value
      end
    end

    context 'hash that is a Ref, but not a parameter' do
      it 'returns hash as-is' do
        cfn_model = CfnModel.new
        ref_hash = {
          'Ref' => 'someOtherRef'
        }
        actual_value = References.resolve_value(cfn_model, ref_hash)
        expected_value = ref_hash

        expect(actual_value).to eq expected_value
      end
    end

    context 'hash that is a Ref but has (illegal?) data structure for value' do
      it 'returns hash as-is' do
        cfn_model = CfnModel.new
        ref_hash = {
          'Ref' => {'something_weird':'verboten'}
        }
        actual_value = References.resolve_value(cfn_model, ref_hash)
        expected_value = ref_hash

        expect(actual_value).to eq expected_value
      end
    end

    context 'hash that is a Ref to a parameter' do
      it 'returns hash as-is' do
        cfn_model = CfnModel.new

        parm1 = Parameter.new
        parm1.synthesized_value = 'happyvalue'
        cfn_model.parameters['Parm1'] = parm1
        ref_hash = {
          'Ref' => 'Parm1'
        }
        actual_value = References.resolve_value(cfn_model, ref_hash)
        expected_value = 'happyvalue'

        expect(actual_value).to eq expected_value
      end
    end

    context 'hash that is a FindInMap to something static' do
      it 'returns static value' do
        cfn_model = CfnModel.new
        cfn_model.mappings['AWSRegionArch2AMI'] = {
          "us-east-1" => {"HVM64" => "ami-0080e4c5bc078760e", "HVMG2" => "ami-0aeb704d503081ea6"},
          "eu-west-2" => {"HVM64" => "ami-01419b804382064e4", "HVMG2" => "NOT_SUPPORTED"}
        }
        ref_find_in_map = {
          'Fn::FindInMap' => %w[AWSRegionArch2AMI us-east-1 HVMG2]
        }
        actual_value = References.resolve_value(cfn_model, ref_find_in_map)
        expected_value = 'ami-0aeb704d503081ea6'

        expect(actual_value).to eq expected_value
      end
    end

    context 'hash that is a FindInMap using pseudo function', :moo do
      it 'returns the findinmap' do
        cloudformation_yml = <<END
---
Mappings:
  AWSRegionArch2AMI:
    us-east-1:
      HVM64: ami-0080e4c5bc078760e
      HVMG2: ami-0aeb704d503081ea6
    eu-west-2:
      HVM64: ami-01419b804382064e4
      HVMG2: NOT_SUPPORTED

Resources:
  newResource:
    Type: "AWS::TimeTravel::Machine"
    Properties:
      Fuel: !FindInMap
        - AWSRegionArch2AMI
        - !Ref AWS::Region
        - HVMG2
END
        cfn_model = CfnParser.new.parse cloudformation_yml,parameter_values_json='{"Parameters":{}}'

        actual_value = cfn_model.resources['newResource'].fuel
        expected_value = 'ami-0aeb704d503081ea6'
        expect(actual_value).to eq expected_value

        cfn_model = CfnParser.new.parse cloudformation_yml,parameter_values_json='{"Parameters":{"AWS::Region":"eu-west-2"}}'
        actual_value = cfn_model.resources['newResource'].fuel
        expected_value = 'NOT_SUPPORTED'
        expect(actual_value).to eq expected_value
      end
    end
  end

  context 'nested FindInMap', :moo do
    it 'returns the proper value from the nested map' do
      cloudformation_yml = <<END
---
Mappings:
  Arch:
    us-east-1:
      arch: HVM64

  AWSRegionArch2AMI:
    us-east-1:
      HVM64: ami-0080e4c5bc078760e
      HVMG2: ami-0aeb704d503081ea6
    eu-west-2:
      HVM64: ami-01419b804382064e4
      HVMG2: NOT_SUPPORTED

Resources:
  newResource:
    Type: "AWS::TimeTravel::Machine"
    Properties:
      Fuel: !FindInMap
        - AWSRegionArch2AMI
        - !Ref AWS::Region
        - !FindInMap
          - Arch
          - !Ref AWS::Region
          - arch
END
      cfn_model = CfnParser.new.parse cloudformation_yml,parameter_values_json='{"Parameters":{}}'

      actual_value = cfn_model.resources['newResource'].fuel
      expected_value = 'ami-0080e4c5bc078760e'
      expect(actual_value).to eq expected_value
    end
  end

  context 'parameter based key', :moo do
    it 'returns the proper value from the map' do
      cloudformation_yml = <<END
---
Parameters:
  MyKey:
    Type: String

Mappings:
  AWSRegionArch2AMI:
    us-east-1:
      HVM64: ami-0080e4c5bc078760e
      HVMG2: ami-0aeb704d503081ea6
    eu-west-2:
      HVM64: ami-01419b804382064e4
      HVMG2: NOT_SUPPORTED

Resources:
  newResource:
    Type: "AWS::TimeTravel::Machine"
    Properties:
      Fuel: !FindInMap
        - AWSRegionArch2AMI
        - !Ref AWS::Region
        - !Ref MyKey
END
      cfn_model = CfnParser.new.parse cloudformation_yml,parameter_values_json='{"Parameters":{"MyKey":"HVM64","AWS::Region":"eu-west-2"}}'

      actual_value = cfn_model.resources['newResource'].fuel
      expected_value = 'ami-01419b804382064e4'
      expect(actual_value).to eq expected_value
    end
  end

  context 'missing parameter based key', :moo do
    it 'returns the proper value from the map' do
      cloudformation_yml = <<END
---
Parameters:
  MyKey:
    Type: String
Mappings:
  AWSRegionArch2AMI:
    us-east-1:
      HVM64: ami-0080e4c5bc078760e
      HVMG2: ami-0aeb704d503081ea6
    eu-west-2:
      HVM64: ami-01419b804382064e4
      HVMG2: NOT_SUPPORTED

Resources:
  newResource:
    Type: "AWS::TimeTravel::Machine"
    Properties:
      Fuel: !FindInMap
        - AWSRegionArch2AMI
        - !Ref AWS::Region
        - !Ref MyKey
END
      cfn_model = CfnParser.new.parse cloudformation_yml,parameter_values_json='{"Parameters":{}}'

      actual_value = cfn_model.resources['newResource'].fuel
      expected_value = {'Fn::FindInMap' => ['AWSRegionArch2AMI', {'Ref'=>'AWS::Region'},{'Ref'=>'MyKey'}]}
      expect(actual_value).to eq expected_value
    end
  end

end
