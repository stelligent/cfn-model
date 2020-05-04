require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a template with a security group without a group description' do
    it 'returns a parse error' do
      test_templates('security_group/security_group_without_description').each do |test_template|
        begin
          _ = @cfn_parser.parse IO.read(test_template)
        rescue Exception => parse_error
          begin
            expect(parse_error.is_a?(ParserError)).to eq true
            expect(parse_error.errors.size).to eq(1)
            expect(parse_error.errors[0].to_s).to eq("[/Resources/sgNoDescription/Properties] key 'GroupDescription:' is required.")
          rescue RSpec::Expectations::ExpectationNotMetError
            $!.message << "in file: #{test_template}"
            raise
          end
        end
      end
    end
  end

  context 'a security group without a VpcId' do
    it 'returns a parse error' do
      test_templates('security_group/security_group_without_vpc_id').each do |test_template|
        begin
          _ = @cfn_parser.parse IO.read(test_template)
        rescue Exception => parse_error
          begin
            expect(parse_error.is_a?(ParserError)).to eq true
            expect(parse_error.errors.size).to eq(1)
            expect(parse_error.errors[0].to_s).to eq("[/Resources/sgNoVpcId/Properties] key 'VpcId:' is required.")
          rescue RSpec::Expectations::ExpectationNotMetError
            $!.message << "in file: #{test_template}"
            raise
          end
        end
      end
    end
  end

  context 'a security group with no ingress and no egress rules' do
    it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
      expected_security_groups = [
        security_group_with_no_rules
      ]

      test_templates('security_group/valid_security_group_with_no_ingress_and_no_egress').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end

  context 'a security group with one ingress and no egress rules' do
    it 'returns a size-1 collection of SecurityGroup object with size-1 collection of ingress rules' do
      expected_security_groups = [
        security_group_with_one_ingress_rule
      ]

      test_templates('security_group/valid_security_group_with_single_ingress').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end

  context 'a security group with one ingress with -1 IP protocol' do
    it 'returns a size-1 collection of SecurityGroup object with size-1 collection of ingress rules' do
      expected_security_groups = [
          security_group_with_one_ingress_rule_ipprotocol
      ]

      test_templates('security_group/valid_security_group_with_single_ingress_ip_protocol').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end


  context 'a stand alone ingress with -1 IP Protocol' do
    it 'returns a size-1 collection of SecurityGroupIngress rules' do
      expected_security_groups = [
          standalone_ingress_rule_ip_protocol
      ]

      test_templates('security_group/valid_standalone_ingress_ipprotocol').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.standalone_ingress).to eq expected_security_groups
      end
    end
  end

  context 'a security group with two externalized ingress' do
    it 'returns a size-1 collection of SecurityGroup object with size-1 collection of ingress rules' do
      expected_security_groups = [
        security_group_with_two_ingress_rules(id: 'sg3') do |_, ingress_rule1, ingress_rule2|
          ingress_rule1.groupId =  { 'Ref' => 'sg3' }
          ingress_rule2.groupId =  { 'Ref' => 'sg3' }
        end
      ]

      test_templates('security_group/valid_security_group_with_externalized_ingress').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end


  context 'a security group and an ingress with a GroupId that is an ImportedValue' do
    it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
      expected_security_groups = [
        security_group_with_no_rules
      ]

      test_templates('security_group/valid_standalone_ingress_with_imported_group_id').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end

  context 'a security group and an ingress with a GroupId that is an nested stack output', :bad do
    it 'returns a size-1 collection of SecurityGroup object with size-0 collection of rules' do
      expected_security_groups = [
        security_group_with_no_rules
      ]

      test_templates('security_group/valid_standalone_ingress_with_nested_stack_reference').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end

  # @todo
  context 'a security group with one externalized ingress - using GetAtt(GroupId)' do
    it 'returns a size-1 collection of SecurityGroup object with size-2 collection of ingress rules' do
      expected_security_groups = [
        security_group_with_two_ingress_rules(id: 'sg3') do |_, ingress_rule1, ingress_rule2|
          ingress_rule1.groupId = {'Fn::GetAtt' => %w(sg3 GroupId)}
          ingress_rule2.groupId = {'Fn::GetAtt' => %w(sg3 GroupId)}
        end
      ]

      # the json and yml structure yield different GroupId which I don't think we need to care about at leat yet
      # need separate test data for json/yml
      yaml_test_templates('security_group/valid_security_group_with_externalized_ingress_via_getatt').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end

  context 'a security group with one externalized ingress with a bad Ref for GroupId' do
    it 'returns a ParserError' do
      test_templates('security_group/security_group_with_invalid_standalone_ingress').each do |test_template|
        expect {
          _ = @cfn_parser.parse IO.read(test_template)
        }.to raise_error(ParserError, 'Unresolved logical resource ids: ["cantfindthis"]')
      end
    end
  end

  context 'a security group with one externalized ingress with a bad Ref for GroupId' do
    it 'returns a ParserError' do
      test_templates('security_group/security_group_with_invalid_standalone_getatt').each do |test_template|
        expect {
          _ = @cfn_parser.parse IO.read(test_template)
        }.to raise_error(ParserError, 'Unresolved logical resource ids: ["reallycantfindit"]')
      end
    end
  end

  context 'a security group with one inline and one externalized egress - using Ref(GroupId)' do
    it 'returns a size-2 collection of SecurityGroup object with size-1 collection of egress rules' do
      expected_security_groups = [
        security_group_with_one_external_egress_rule(security_group_id: 'sg1', egress_group_id: {'Ref' => 'sg1'}) do |sg, _|
          sg.tags = [
            {
              'Key' => 'Vintage',
              'Value' => '1995'
            }
          ]
        end,
        security_group_with_one_ingress_and_one_egress_rule(id: 'sg2'),
        security_group_with_one_egress_rule(security_group_id: 'sg3', egress_group_id: nil) do |_, egress_rule, raw_egress|
          egress_rule.cidrIp = '1.2.3.5/32'
          egress_rule.fromPort = 57
          egress_rule.toPort = 58

          raw_egress['CidrIp'] = '1.2.3.5/32'
          raw_egress['FromPort'] = 57
          raw_egress['ToPort'] = 58
        end
      ]

      test_templates('security_group/valid_security_group_with_egress').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end

  context 'a security group with one externalized egress with a bad Ref for GroupId' do
    it 'returns a ParserError' do
      test_templates('security_group/security_group_with_invalid_standalone_egress').each do |test_template|
        expect {
          _ = @cfn_parser.parse IO.read(test_template)
        }.to raise_error(ParserError, 'Unresolved logical resource ids: ["cantfindthis"]')
      end
    end
  end

  context 'when security group has Fn::If as an inline ingress' do
    it 'maps the Fn::If to a hash and skips objectification of it' do
      yaml_test_templates('security_group/pesky_if').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expectation = [
          {
            'CidrIp' => '10.1.2.4/32',
            'FromPort' => 44,
            'ToPort' => 46,
            'IpProtocol' => 'tcp'
          }
        ]
        expect(cfn_model.resources_by_type('AWS::EC2::SecurityGroup').first.securityGroupIngress).to eq expectation
      end
    end
  end

  context 'a security group with one egress with -1 IP protocol' do
    it 'returns a size-1 collection of SecurityGroup object with size-1 collection of egress rules' do
      expected_security_groups = [
          security_group_with_one_egress_rule_ipprotocol
      ]

      yaml_test_templates('security_group/valid_security_group_with_single_egress_ip_protocol').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.security_groups).to eq expected_security_groups
      end
    end
  end


  context 'a stand alone egress with -1 IP Protocol' do
    it 'returns a size-1 collection of SecurityGroupEgress rules' do
      expected_security_groups = [
          standalone_egress_rule_ip_protocol
      ]

      yaml_test_templates('security_group/valid_standalone_egress_ipprotocol').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        expect(cfn_model.standalone_egress).to eq expected_security_groups
      end
    end
  end

  context 'egresses are parameterized' do
    it 'maps the Fn::If to a hash and skips objectification of it' do
      yaml_test_templates('security_group/security_group_with_parameterized_egress').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template),
                                      IO.read('spec/test_templates/yaml/security_group/egress.json')


        # puts cfn_model.resources['sg2'].egresses
        expect(cfn_model.resources['sg2'].egresses.first.cidrIp).to eq '1.2.3.4/24'
        expect(cfn_model.resources['sg1'].egresses.first.cidrIp).to eq '0.0.0.0/0'
      end
    end
  end
end#
