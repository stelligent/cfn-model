require 'spec_helper'
require 'cfn-model/parser/policy_document_parser'

describe PolicyDocumentParser do
  before(:each) do
    @policy_document_parser = PolicyDocumentParser.new
  end

  context 'single statement (as hash)' do
    it 'returns statement array with 1 element' do
      raw_policy_document = {}

      raw_policy_document['Version'] = '1234'
      raw_policy_document['Statement'] = {
        'Effect' => 'Allow',
        'Resource' => '*',
        'Action' => '*'
      }

      policy_document = @policy_document_parser.parse CfnModel.new, raw_policy_document

      expect(policy_document.version).to eq '1234'
      expect(policy_document.statements.size).to eq 1
      expect(policy_document.statements.first.actions).to eq %w(*)
      expect(policy_document.statements.first.resources).to eq %w(*)
      expect(policy_document.statements.first.effect).to eq 'Allow'
    end
  end

  context 'two statements (as array)' do
    it 'returns statement array with 2 elements' do
      raw_policy_document = {}

      raw_policy_document['Version'] = '1234'
      raw_policy_document['Statement'] = [
        {
          'Effect' => 'Allow',
          'Resource' => '*',
          'Action' => '*'
        },
        {
          'Effect' => 'Deny',
          'NotResource' => 'arn:foo',
          'NotAction' => %w(sts:moo s3:yowzer),
          'Condition' => {
            'DateGreaterThan' => {
              'aws:CurrentTime' => '2013-12-15T12:00:00Z'
            }
          }
        }
      ]

      policy_document = @policy_document_parser.parse CfnModel.new, raw_policy_document

      expect(policy_document.version).to eq '1234'
      expect(policy_document.statements.size).to eq 2

      expect(policy_document.statements.first.actions).to eq %w(*)
      expect(policy_document.statements.first.resources).to eq %w(*)
      expect(policy_document.statements.first.effect).to eq 'Allow'

      expect(policy_document.statements[1].not_actions).to eq %w(sts:moo s3:yowzer)
      expect(policy_document.statements[1].not_resources).to eq %w(arn:foo)
      expect(policy_document.statements[1].condition).to eq({
        'DateGreaterThan' => {
          'aws:CurrentTime' => '2013-12-15T12:00:00Z'
        }
      })
      expect(policy_document.statements[1].effect).to eq 'Deny'
    end
  end
end
