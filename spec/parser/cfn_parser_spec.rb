require 'spec_helper'
require 'parser/cfn_parser'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'a yml template' do
    context 'an empty template' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse('')
        }.to raise_error 'yml empty'

        expect {
          @cfn_parser.parse('---')
        }.to raise_error 'yml empty'
      end
    end

    context 'a template with missing Resources' do
      it 'returns a parse error' do

        expect {
          @cfn_parser.parse <<END
---
Parameters: {}
END
        }.to raise_error 'Illegal cfn - no Resources'

      end
    end

    context 'a template with empty Resources' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse <<END
---
Parameters: {}
Resources: {}
END
        }.to raise_error 'Illegal cfn - no Resources'
      end
    end
  end

  context 'a json template' do
    context 'an empty template' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse('')
        }.to raise_error 'yml empty'

        expect {
          @cfn_parser.parse('{}')
        }.to raise_error 'Illegal cfn - no Resources'
      end
    end

    context 'a template with missing Resources' do
      it 'returns a parse error' do

        expect {
          @cfn_parser.parse <<END
{
  "Parameters": {}
}
END
        }.to raise_error 'Illegal cfn - no Resources'

      end
    end

    context 'a template with empty Resources' do
      it 'returns a parse error' do
        expect {
          @cfn_parser.parse <<END
{
"Parameters": {},
"Resources": {}
}
END
        }.to raise_error 'Illegal cfn - no Resources'
      end
    end
  end
end
