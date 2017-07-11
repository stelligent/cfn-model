require 'spec_helper'
require 'cfn-model/model/policy_document'

describe PolicyDocument do
  describe '#allows_not_principal' do
    context 'statement that is Allow + NotPrincipal is set' do
      it 'returns array with the Statement' do
        ok_statement = Statement.new
        ok_statement.effect = 'Allow'
        ok_statement.principal = {
          'AWS' => '1234'
        }

        bad_statement = Statement.new
        bad_statement.effect = 'Allow'
        bad_statement.not_principal = {
          'AWS' => '1234'
        }

        policy_document = PolicyDocument.new
        policy_document.statements << ok_statement
        policy_document.statements << bad_statement

        expect(policy_document.allows_not_principal).to eq [bad_statement]
      end
    end
  end
end
