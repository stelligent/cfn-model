require 'spec_helper'
require 'cfn-model/model/statement'

describe Statement do
  describe '#wildcard_actions' do
    context 'no wildcard actions' do
      it 'returns empty array' do
        statement = Statement.new
        statement.actions << 'sts:AssumeRole'
        statement.actions << 'ec2:DescribeInstances'
        expect(statement.wildcard_actions).to eq []
      end
    end

    context 'wildcard actions' do
      it 'returns array with wildcards' do
        statement = Statement.new
        statement.actions << 'sts:Assume*'
        statement.actions << 'ec2:DescribeInstances'
        statement.actions << 'ec2:*'
        expect(statement.wildcard_actions).to eq %w(ec2:*)
      end
    end
  end

  describe '#wildcard_resources' do
    context 'no wildcard resources' do
      it 'returns empty array' do
        statement = Statement.new
        statement.resources << 'arn:aws:iam::123456789012:user/David'
        statement.resources << 'arn:aws:rds:eu-west-1:123456789012:db:mysql-db'
        expect(statement.wildcard_resources).to eq []
      end
    end

    context 'wildcard resources' do
      it 'returns array with wildcards' do
        statement = Statement.new
        statement.resources << 'arn:aws:iam::123456789012:user/David'
        statement.resources << 'arn:aws:s3:::*'
        statement.resources << '*'
        expect(statement.wildcard_resources).to eq %w(*)
      end
    end
  end
end
