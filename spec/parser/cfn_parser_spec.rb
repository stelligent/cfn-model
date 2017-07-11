require 'spec_helper'
require 'cfn-model/parser/cfn_parser'

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

    context 'a template with unforeseen resource type' do
      it 'creates a dynamic object on the fly' do
        cloudformation_yml = <<END
---
Resources:
  newResource:
    Type: "AWS::TimeTravel::Machine"
    Properties:
      Fuel: dilithium
END
        cfn_model = @cfn_parser.parse cloudformation_yml

        expect(cfn_model.resources.size).to eq 1

        time_travel_machine = cfn_model.resources_by_type('AWS::TimeTravel::Machine').first
        expect(time_travel_machine.is_a?(DynamicModelElement)).to eq true
        expect(time_travel_machine.fuel).to eq 'dilithium'
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
