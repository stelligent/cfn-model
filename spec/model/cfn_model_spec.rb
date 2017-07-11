require 'spec_helper'
require 'cfn-model/model/cfn_model'

describe CfnModel, :model do
  before(:each) do
    @cfn_model = CfnModel.new
  end

  describe '#standalone_ingress' do
    context 'no ingress resources' do
      it 'returns empty array' do
        expect(@cfn_model.standalone_ingress).to eq []
      end
    end

    context 'ingress resource that points to internal sg' do
      it 'returns empty array' do
        @cfn_model.resources['ingress'] = AWS::EC2::SecurityGroupIngress.new
        @cfn_model.resources['ingress'].groupId = {
          'Ref' => 'secGroup'
        }
        expect(@cfn_model.standalone_ingress).to eq []
      end
    end

    context 'ingress resource that points to external sg' do
      it 'returns array with the ingress resource' do
        @cfn_model.resources['ingress'] = AWS::EC2::SecurityGroupIngress.new
        @cfn_model.resources['ingress'].groupId = {
          'Fn::ImportValue' => 'foo'
        }

        expect(@cfn_model.standalone_ingress).to eq [@cfn_model.resources['ingress']]
      end
    end
  end
end
