require 'spec_helper'
require 'cfn-model/model/principal'

describe Principal, :prin do
  describe '#wildcard?' do
    context '*' do
      it 'returns true' do
        expect(Principal.wildcard?('*')).to eq true
      end
    end

    context '{"AWS":"*"}' do
      it 'returns true' do
        aws_wildcard_principal = {
          'AWS' => '*'
        }
        expect(Principal.wildcard?(aws_wildcard_principal)).to eq true

      end
    end

    context '{"AWS":["*", "fred"]}' do
      it 'returns true' do
        aws_wildcard_principal = {
          'AWS' => ['*', 'fred']
        }
        expect(Principal.wildcard?(aws_wildcard_principal)).to eq true

      end
    end

    context '{"AWS":["1234", "fred"]}' do
      it 'returns false' do
        aws_wildcard_principal = {
          'AWS' => ['1234', 'fred']
        }
        expect(Principal.wildcard?(aws_wildcard_principal)).to eq false
      end
    end

    context '{"AWS":["1234", Ref]}', :fred do
      it 'returns false' do
        aws_wildcard_principal = {
          'AWS' => [
            '1234',
            {'Ref' => 'SomePrincipal'}
          ]
        }
        expect(Principal.wildcard?(aws_wildcard_principal)).to eq false
      end
    end

    context 'nil principal' do
      it 'returns false' do
        expect(Principal.wildcard?(nil)).to eq false
      end
    end

    context 'principal object with > 1 key and a wildcard' do
      it 'returns true' do
        multiple_principals = {
          'Service' => 'ec2.amazon.com',
          'AWS' => %w(1234 *),
        }
        expect(Principal.wildcard?(multiple_principals)).to eq true
      end
    end

    context 'principal object with > 1 key and no wildcard' do
      it 'returns false' do
        multiple_principals = {
          'Service' => 'ec2.amazon.com',
          'AWS' => %w(1234 6666),
        }
        expect(Principal.wildcard?(multiple_principals)).to eq false
      end
    end

    context 'not a String or Hash' do
      it 'raises an error' do
        expect{
          _ = Principal.wildcard?(['*'])
        }.to raise_error 'whacky principal not string or hash: ["*"]'
      end
    end
  end
end
