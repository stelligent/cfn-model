require 'spec_helper'
require 'cfn-model/model/lambda_principal'

describe LambdaPrincipal, :prin do
  describe '#wildcard?' do
    context '*' do
      it 'returns true' do
        expect(LambdaPrincipal.wildcard?('*')).to eq true
      end
    end

    context 's3.amazonaws.com' do
      it 'returns false' do
        expect(LambdaPrincipal.wildcard?('s3.amazonaws.com')).to eq false
      end
    end

    context 'integer account id' do
      it 'returns true' do
        aws_account_id = 1234234525
        expect(LambdaPrincipal.wildcard?(aws_account_id)).to eq false
      end
    end

    context 'not a String or Integer' do
      it 'raises an error' do
        expect{
          _ = LambdaPrincipal.wildcard?(['*'])
        }.to raise_error 'whacky lambda principal not string or int: ["*"]'
      end
    end
  end
end
