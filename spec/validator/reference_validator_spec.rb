require 'spec_helper'
require 'cfn-model/validator/reference_validator'
require 'cfn-model/parser/parser_error'

describe ReferenceValidator, :refv do
  before(:each) do
    YAML.add_domain_type('', 'GetAtt') { |type, val| { 'Fn::GetAtt' => val } }
    YAML.add_domain_type('', 'Ref') { |type, val| { 'Ref' => val } }
    @reference_validator = ReferenceValidator.new
  end

  context 'missing Ref target to dino' do
    it 'returns set of missing ref target dino' do
      cfn_yaml_with_missing_ref = <<END
---
Resources:
  someResource:
    Properties:
      Fred: wilma
  someResource2:
    Properties:
      Barney: !Ref dino
      JimBob: !Ref someResource
END

      unresolved_references = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_missing_ref)
      expect(unresolved_references).to eq Set.new(%w(dino))
    end
  end

  context 'missing Ref target to dino down in second level' do
    it 'returns set of missing ref target dino' do
      cfn_yaml_with_missing_ref = <<END
---
Parameters:
  someParameter:
    Type: String

Resources:
  someResource:
    Properties:
      Fred: wilma
  someResource2:
    Properties:
      Barney: 
        Genus: foo
        Species: !Ref dino
      JimBob: !Ref someResource
END

      unresolved_references = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_missing_ref)
      expect(unresolved_references).to eq Set.new(%w(dino))
    end
  end

  context 'malformed Ref (non-literal target)' do
    it 'raises an error' do
      cfn_yaml_with_missing_ref = <<END
---
Resources:
  someResource:
    Properties:
      Fred: wilma
  someResource2:
    Properties:
      Barney: !Ref dino
      JimBob:
        Ref:
          Fn::GetAtt:
            - someResource
            - Fred
END

      expect {
        _ = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_missing_ref)
      }.to raise_error(ParserError, 'Ref target must be string literal: {"Ref"=>{"Fn::GetAtt"=>["someResource", "Fred"]}}')
    end
  end

  context 'a pseudo-ref' do
    it 'ignores the pseudo-ref' do
      cfn_yaml_with_missing_ref = <<END
---
Resources:
  someResource:
    Properties:
      Fred: wilma
  someResource2:
    Properties:
      Barney: !Ref AWS::Region
END

      unresolved_references = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_missing_ref)
      expect(unresolved_references).to eq Set.new([])
    end
  end

  context 'missing Fn::GetATt target to dino2 down in second level - shorthand string' do
    it 'returns set of missing ref target dino2' do
      cfn_yaml_with_missing_ref = <<END
---
Parameters:
  someParameter:
    Type: String

Resources:
  someResource:
    Properties:
      Fred: wilma
  someResource2:
    Properties:
      Barney: 
        Genus: foo
        Species: !GetAtt dino2.Species
      JimBob: !Ref someResource
END

      unresolved_references = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_missing_ref)
      expect(unresolved_references).to eq Set.new(%w(dino2))
    end
  end


  context 'missing Fn::GetATt target to dino2 down in second level - array' do
    it 'returns set of missing ref target dino2' do
      cfn_yaml_with_missing_ref = <<END
---
Parameters:
  someParameter:
    Type: String

Resources:
  someResource:
    Properties:
      Fred: wilma
  someResource2:
    Properties:
      Barney: 
        Genus: foo
        Species: 
          Fn::GetAtt:
            - dino2
            - Species
      JimBob: !Ref someResource
END

      unresolved_references = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_missing_ref)
      expect(unresolved_references).to eq Set.new(%w(dino2))
    end
  end

  context '.Alias and .Version pseudorefs to legit resources' do
    it 'ignores them' do
      cfn_yaml_with_pseudo_refs = <<END
---
Parameters:
  someParameter:
    Type: String

Resources:
  someResource:
    Properties:
      Fred: wilma

  someResource2:
    Properties:
      Barney: 
        Genus: foo
      JimBob: !Ref someResource.Alias
      Ricky: !Ref someResource.Version
END

      unresolved_references = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_pseudo_refs)
      expect(unresolved_references).to eq Set.new(%w())
    end
  end

  context '.Alias and .Version pseudorefs to missing resources' do
    it 'ignores them' do
      cfn_yaml_with_pseudo_refs = <<END
---
Parameters:
  someParameter:
    Type: String

Resources:
  someResource:
    Properties:
      Fred: wilma

  someResource2:
    Properties:
      Barney: 
        Genus: foo
      JimBob: !Ref someResource.Alias
      Ricky: !Ref bogus.Version
END

      unresolved_references = ReferenceValidator.new.unresolved_references YAML.safe_load(cfn_yaml_with_pseudo_refs)
      expect(unresolved_references).to eq Set.new(%w(bogus.Version))
    end
  end
end
