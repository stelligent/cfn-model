require 'spec_helper'
require 'parser/json/security_group_json_parser'
require 'model/security_group'
require 'model/security_group_ingress'
require 'parser/parser_error'
require 'factories/security_group'

describe SecurityGroupJsonParser do
  before(:each) do
    @security_group_parser = SecurityGroupJsonParser.new
  end

  context 'a json template' do
    context 'a security group without a GroupDescription' do
      it 'returns a parse error' do
        expect {
          @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/security_group_without_description.json')
        }.to raise_error 'sg SecurityGroup missing GroupDescription'
      end
    end

    context 'a security group without a VpcId' do
      it 'returns a parse error' do
        expect {
          @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/security_group_without_vpc_id.json')
        }.to raise_error 'sg SecurityGroup missing VpcId'
      end
    end

    context 'a security group with no ingress and no egress rules' do
      it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
        expected_security_groups = [
          security_group_with_no_rules
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/valid_security_group_with_no_ingress_and_no_egress.json')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one ingress and no egress rules' do
      it 'returns a size-1 collection of SecurityGroup object with size-1 collection of ingress rules' do
        expected_security_groups = [
          security_group_with_one_ingress_rule
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/valid_security_group_with_single_ingress.json')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one externalized ingress' do
      it 'returns a size-1 collection of SecurityGroup object with size-1 collection of ingress rules' do
        expected_security_groups = [
          security_group_with_one_ingress_rule(security_group_id: 'sg3',
                                               ingress_group_id: { 'Ref' => 'sg3' })
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/valid_security_group_with_externalized_ingress.json')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group and an ingress with a GroupId that is an ImportedValue' do
      it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
        expected_security_groups = [
          security_group_with_no_rules
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/valid_standalone_ingress_with_imported_group_id.json')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group and an ingress with a GroupId that is an nested stack output' do
      it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
        expected_security_groups = [
          security_group_with_no_rules
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/valid_standalone_ingress_with_nested_stack_reference.json')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one externalized ingress - using GetAtt(GroupId)' do
      it 'returns a size-1 collection of SecurityGroup object with size-1 collection of ingress rules' do
        expected_security_groups = [
          security_group_with_one_ingress_rule(security_group_id: 'sg3',
                                               ingress_group_id:  {'Fn::GetAtt' => %w(sg3 GroupId)})
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/valid_security_group_with_externalized_ingress_via_getatt.json')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one externalized ingress with a bad Ref for GroupId' do
      it 'returns a ParserError' do
        expect {
          _ = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/security_group_with_invalid_standalone_ingress.json')
        }.to raise_error(ParserError, 'Ingress referencing non-existent security group: cantfindthis')
      end
    end

    context 'a security group with one externalized ingress with a bad Ref for GroupId' do
      it 'returns a ParserError' do
        expect {
          _ = @security_group_parser.parse direct_model: direct_json_model(test_file: 'security_group/security_group_with_invalid_standalone_getatt.json')
        }.to raise_error(ParserError, 'Ingress referencing non-existent security group: reallycantfindit')
      end
    end
  end
end
