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
        @cfn_model.resources['ingress'] = AWS::EC2::SecurityGroupIngress.new @cfn_model
        @cfn_model.resources['ingress'].groupId = {
          'Ref' => 'secGroup'
        }
        expect(@cfn_model.standalone_ingress).to eq []
      end
    end

    context 'ingress resource that points to external sg' do
      it 'returns array with the ingress resource' do
        @cfn_model.resources['ingress'] = AWS::EC2::SecurityGroupIngress.new @cfn_model
        @cfn_model.resources['ingress'].groupId = {
          'Fn::ImportValue' => 'foo'
        }

        expect(@cfn_model.standalone_ingress).to eq [@cfn_model.resources['ingress']]
      end
    end
  end

  describe '#copy' do
    context 'when copy is made and resource is removed from copy' do
      it 'the original model still has the resource' do
        ingress1 = AWS::EC2::SecurityGroupIngress.new @cfn_model
        @cfn_model.resources['ingress1'] = ingress1

        ingress2 = AWS::EC2::SecurityGroupIngress.new @cfn_model
        @cfn_model.resources['ingress2'] = ingress2

        cfn_model_copy = @cfn_model.copy
        cfn_model_copy.resources.delete 'ingress2'
        expect(@cfn_model.resources['ingress2']).to eq ingress2
      end
    end
  end
end
