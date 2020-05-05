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
          'Ref' => {'something_weird' => 'verboten'}
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

    context 'hash that is a FindInMap using pseudo function' do
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

  context 'nested FindInMap' do
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

  context 'parameter based key' do
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

  context 'missing parameter based key' do
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

  context 'embedded ref' do
    it 'substitutues the embedded ref' do
      cloudformation_yml = <<END
Parameters:
  Resource:
    Type: String

Resources:
  HelperRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
            Path: /
      Policies:
        - PolicyName: awstestingLambdaExecutePolicies
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - tag:TagResources
                  - tag:UntagResources
                  - elasticloadbalancing:DescribeLoadBalancerAttributes
                  - elasticloadbalancing:DescribeLoadBalancers
                  - elasticloadbalancing:AddTags
                  - elasticloadbalancing:RemoveTags
                  - elasticloadbalancing:ModifyLoadBalancerAttributes
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                  - s3:GetBucketPolicy
                  - s3:PutBucketPolicy
                Resource: !Ref Resource
END
      cfn_model = CfnParser.new.parse cloudformation_yml,parameter_values_json='{"Parameters":{"Resource":"*"}}'

      actual_value = cfn_model.resources['HelperRole'].policies.first['PolicyDocument']['Statement'].first['Resource']
      expected_value = '*'
      expect(actual_value).to eq expected_value
    end
  end

  context 'embedded if' do
    it 'substitutes the true condition' do
      cloudformation_yml = <<END
Conditions:
  MicroInt: true

Mappings:
  AccountTypeCIDRMap:
    micro-int: 
      California: 1.2.3.4/32

Resources:
  SecGroup:
    Type: AWS::EC2::SecurityGroup
    Properties: 
      GroupDescription: moocow
      GroupName: zootime
      SecurityGroupEgress: 
        - IpProtocol: icmp
          FromPort: '-1'
          ToPort: '-1'
          CidrIp: 0.0.0.0/0
        - !If
          - MicroInt
          - IpProtocol: '-1'
            FromPort: '-1'
            ToPort: '-1'
            CidrIp: !FindInMap [AccountTypeCIDRMap, micro-int, California]
          - {}
      VpcId: vpc-1234
END
      cfn_model = CfnParser.new.parse cloudformation_yml

      actual_value = cfn_model.resources['SecGroup'].securityGroupEgress[1]['CidrIp']
      expected_value = '1.2.3.4/32'
      expect(actual_value).to eq expected_value
    end
  end

  context 'sub to a parameter', :moo9 do
    it 'substitutes the parameter value' do
      cloudformation_yml = <<END
Parameters:
  Parm1:
    Type: String
  Parm2:
    Type: String

Resources:
  Bucket:
    Type: AWS::S3::Bucket
    Properties: 
      BucketName: !Sub ThisName${Parm1}ThatName${Parm2}${Parm1}
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{"Parm1":"moo","Parm2":"cow"}}'

      actual_value = cfn_model.resources['Bucket'].bucketName
      expected_value = 'ThisNamemooThatNamecowmoo'
      expect(actual_value).to eq expected_value
    end
  end

  context 'literal sub', :moo9 do
    it 'leaves it alone' do
      cloudformation_yml = <<END
Parameters:
  Parm1:
    Type: String
  Parm2:
    Type: String

Resources:
  Bucket:
    Type: AWS::S3::Bucket
    Properties: 
      BucketName: !Sub ThisName${Parm1}ThatName${!Parm2}${Parm1}
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{"Parm1":"moo","Parm2":"cow"}}'

      actual_value = cfn_model.resources['Bucket'].bucketName
      expected_value = 'ThisNamemooThatName${!Parm2}moo'
      expect(actual_value).to eq expected_value
    end
  end

  context 'sub to an attribute', :moo9 do
    it 'leaves it alone' do
      cloudformation_yml = <<END
Parameters:
  Parm1:
    Type: String
  Parm2:
    Type: String

Resources:
  Bucket2:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: Fred
  Bucket:
    Type: AWS::S3::Bucket
    Properties: 
      BucketName: !Sub ThisName${Parm1}ThatName${Bucket2.Arn}${Parm1}
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{"Parm1":"moo","Parm2":"cow"}}'

      actual_value = cfn_model.resources['Bucket'].bucketName
      expected_value = 'ThisNamemooThatName${Bucket2.Arn}moo'
      expect(actual_value).to eq expected_value
    end
  end

  context 'sub to a resource', :moo9 do
    it 'ignores the resource value' do
      cloudformation_yml = <<END
Parameters:
  Parm1:
    Type: String
  Parm2:
    Type: String

Resources:
  Bucket2:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: Fred
  Bucket:
    Type: AWS::S3::Bucket
    Properties: 
      BucketName: !Sub ThisName${Parm1}ThatName${Bucket2}${Parm1}
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{"Parm1":"moo","Parm2":"cow"}}'

      actual_value = cfn_model.resources['Bucket'].bucketName
      expected_value = 'ThisNamemooThatName${Bucket2}moo'
      expect(actual_value).to eq expected_value
    end
  end

  context 'long form sub', :moo9 do
    it 'substitutes parameter references' do
      cloudformation_yml = <<END
Parameters:
  Parm1:
    Type: String
  Parm2:
    Type: String

Resources:
  Bucket2:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: Fred
  Bucket:
    Type: AWS::S3::Bucket
    Properties: 
      BucketName: !Sub 
        - ThisName${Parm1}ThatName${Bucket2}${Parm1}${Parm3}
        - { Parm1: !Ref Parm2, Parm3: !GetAtt Bucket2.Arn }
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{"Parm1":"moo","Parm2":"zowee"}}'

      actual_value = cfn_model.resources['Bucket'].bucketName
      expected_value = 'ThisNamezoweeThatName${Bucket2}zowee${Parm3}'
      expect(actual_value).to eq expected_value
    end
  end

  context 'reference to getazs', :moo9 do
    it 'substitutes fake azs' do
      cloudformation_yml = <<END
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: "10.0.0.0/16"
      EnableDnsSupport: true
      EnableDnsHostnames: true
      InstanceTenancy: "default"
  mySubnet: 
    Type: "AWS::EC2::Subnet"
    Properties: 
      VpcId: 
        !Ref VPC
      CidrBlock: 10.0.0.0/24
      AvailabilityZone: 
        Fn::Select: 
          - 2
          - Fn::GetAZs: ""
  mySubnet2: 
    Type: "AWS::EC2::Subnet"
    Properties: 
      VpcId: 
        !Ref VPC
      CidrBlock: 10.0.0.1/24
      AvailabilityZone: 
        Fn::Select: 
          - 1
          - Fn::GetAZs: eu-west-1
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{"AWS::NumberAZs":3}}'

      actual_value = cfn_model.resources['mySubnet'].availabilityZone
      expected_value = 'us-east-1c'
      expect(actual_value).to eq expected_value

      actual_value = cfn_model.resources['mySubnet2'].availabilityZone
      expected_value = 'eu-west-1b'
      expect(actual_value).to eq expected_value
    end
  end

  context 'reference to split', :moo9 do
    it 'substitutes array' do
      cloudformation_yml = <<END
Parameters:
  Parm1:
    Type: String
  Parm2:
    Type: String

Resources:
  Bucket:
    Type: AWS::S3::Bucket
    Properties: 
      BucketName: !Split [",", !Sub "bread,${Parm1},${Parm2},moo2"]
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{"Parm1":"moo","Parm2":"zowee"}}'

      actual_value = cfn_model.resources['Bucket'].bucketName
      expected_value = %w[bread moo zowee moo2]
      expect(actual_value).to eq expected_value
    end
  end

  context 'reference to base64', :moo9 do
    it 'passes through the value to encode' do
      cloudformation_yml = <<END
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties: 
      UserData:
        Fn::Base64:
          !Sub |
            #!/bin/bash -xe
            yum update -y aws-cfn-bootstrap
            /opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchConfig --configsets wordpress_install --region ${AWS::Region}
END
      cfn_model = CfnParser.new.parse cloudformation_yml, '{"Parameters":{}}'

      actual_value = cfn_model.resources['MyInstance'].userData
      expected_value = <<END
#!/bin/bash -xe
yum update -y aws-cfn-bootstrap
/opt/aws/bin/cfn-init -v --stack stackname --resource LaunchConfig --configsets wordpress_install --region us-east-1
END
      expect(actual_value).to eq expected_value
    end
  end
end
