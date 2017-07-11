require 'spec_helper'
require 'cfn-model/model/dynamic_model_element'

class SomeResource < DynamicModelElement

end

describe DynamicModelElement do
  context 'an untouched object without any instance variables' do
    it 'assigns an instance variable' do
      some_resource = SomeResource.new
      some_resource.random_property_name = 'uncle_freddie'

      expect(some_resource.random_property_name).to eq 'uncle_freddie'
    end
  end

  context 'an untouched object without any instance variables' do
    it 'returns nil when no instance variable has been set' do
      some_resource = SomeResource.new
      expect(some_resource.random_property_name2).to be_nil
    end
  end
end
