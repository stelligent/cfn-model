require 'spec_helper'
require 'parser/yaml/security_group_yaml_parser'
require 'model/security_group'
require 'model/security_group_ingress'
require 'model/security_group_egress'
require 'parser/parser_error'

describe SecurityGroupYamlParser do
  before(:each) do
    @security_group_parser = SecurityGroupYamlParser.new
  end

  context 'a yaml template' do
    context 'a security group without a GroupDescription' do
      it 'returns a parse error' do
        expect {
          @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/security_group_without_description.yml')
        }.to raise_error 'sg3 SecurityGroup missing GroupDescription'
      end
    end

    context 'a security group without a VpcId' do
      it 'returns a parse error' do
        expect {
          @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/security_group_without_vpc_id.yml')
        }.to raise_error 'sg3 SecurityGroup missing VpcId'
      end
    end

    context 'a security group with no ingress and no egress rules', :fg do
      it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
        expected_security_groups = [
          security_group_with_no_rules
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_security_group_with_no_ingress_and_no_egress.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one ingress and no egress rules' do
      it 'returns a size-1 collection of SecurityGroup object with size-1 collection of ingress rules' do
        expected_security_groups = [
          security_group_with_one_ingress_rule
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_security_group_with_single_ingress.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with two ingress and no egress rules' do
      it 'returns a size-1 collection of SecurityGroup object with size-2 collection of ingress rules' do
        expected_security_groups = [
          security_group_with_two_ingress_rules
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_security_group_with_two_ingress.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with two externalized ingress' do
      it 'returns a size-1 collection of SecurityGroup object with size-2 collection of ingress rules' do
        expected_security_groups = [
          security_group_with_two_ingress_rules(id: 'sg3') do |_, ingress_rule1, ingress_rule2|
            ingress_rule1.groupId =  { 'Ref' => 'sg3' }
            ingress_rule2.groupId =  { 'Ref' => 'sg3' }
          end
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_security_group_with_externalized_ingress.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group and an ingress with a GroupId that is an ImportedValue' do
      it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
        expected_security_groups = [
          security_group_with_no_rules
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_standalone_ingress_with_imported_group_id.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group and an ingress with a GroupId that is an nested stack output', :bad do
      it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
        expected_security_groups = [
          security_group_with_no_rules
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_standalone_ingress_with_nested_stack_reference.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one externalized ingress - using GetAtt(GroupId)' do
      it 'returns a size-1 collection of SecurityGroup object with size-2 collection of ingress rules' do
        expected_security_groups = [
          security_group_with_two_ingress_rules(id: 'sg3') do |_, ingress_rule1, ingress_rule2|
            ingress_rule1.groupId = {'Fn::GetAtt' => 'sg3.GroupId'}
            ingress_rule2.groupId = {'Fn::GetAtt' => %w(sg3 GroupId)}
          end
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_security_group_with_externalized_ingress_via_getatt.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one externalized ingress with a bad Ref for GroupId' do
      it 'returns a ParserError' do
        expect {
          _ = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/security_group_with_invalid_standalone_ingress.yml')
        }.to raise_error(ParserError, 'Ingress referencing non-existent security group: cantfindthis')
      end
    end

    context 'a security group with one externalized ingress with a bad Ref for GroupId' do
      it 'returns a ParserError' do
        expect {
          _ = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/security_group_with_invalid_standalone_getatt.yml')
        }.to raise_error(ParserError, 'Ingress referencing non-existent security group: reallycantfindit')
      end
    end

    context 'a security group with one inline and one externalized egress - using Ref(GroupId)', :egress do
      it 'returns a size-2 collection of SecurityGroup object with size-1 collection of egress rules' do
        expected_security_groups = [
          security_group_with_one_egress_rule(security_group_id: 'sg1', egress_group_id: {'Ref' => 'sg1'}),
          security_group_with_one_ingress_and_one_egress_rule(id: 'sg2'),
          security_group_with_one_egress_rule(security_group_id: 'sg3', egress_group_id: nil) do |_, egress_rule|
            egress_rule.cidrIp = '1.2.3.5/32'
            egress_rule.fromPort = 57
            egress_rule.toPort = 58
          end
        ]

        actual_security_groups = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/valid_security_group_with_egress.yml')
        expect(actual_security_groups).to eq expected_security_groups
      end
    end

    context 'a security group with one externalized egress with a bad Ref for GroupId' do
      it 'returns a ParserError' do
        expect {
          _ = @security_group_parser.parse direct_model: direct_yaml_model(test_file: 'security_group/security_group_with_invalid_standalone_egress.yml')
        }.to raise_error(ParserError, 'Egress referencing non-existent security group: cantfindthis')
      end
    end
  end
end
