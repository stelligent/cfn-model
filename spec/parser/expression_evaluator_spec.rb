require 'cfn-model/parser/expression_evaluator'
describe ExpressionEvaluator do

  context 'literal' do
    it 'returns literal' do
      property_value = 'fred'
      conditions = {}
      actual_evaluation = ExpressionEvaluator.new.evaluate(property_value, conditions)
      expected_evaluation = 'fred'
      expect(actual_evaluation).to eq expected_evaluation
    end
  end

  context 'single level conditional' do
    it 'returns SomeCond=false outcome' do
      property_value = {
        'Fn::If' => %w(
          SomeCond
          fred1
          fred2
        )
      }
      conditions = {'SomeCond'=>false}
      actual_evaluation = ExpressionEvaluator.new.evaluate(property_value, conditions)
      expected_evaluation = 'fred2'
      expect(actual_evaluation).to eq expected_evaluation
    end
  end

  context 'compound conditional' do
    it 'returns the OtherCond2=false outcome' do
      property_value = {
        'Fn::If' => [
          'SomeCond',
          {
            'Fn::If' => [
              'OtherCond',
              {
                'Fn::If' => %w[
                  OtherCond2
                  fred4
                  fred5
                ]
              },
              'fred3'
            ]
          },
          'fred2'
        ]
      }
      conditions = {
        'SomeCond'=>true,
        'OtherCond'=>true,
        'OtherCond2'=>false
      }

      actual_evaluation = ExpressionEvaluator.new.evaluate(property_value, conditions)
      expected_evaluation = 'fred5'
      expect(actual_evaluation).to eq expected_evaluation
    end
  end

  context 'properties level' do
    it 'returns true outcome' do
      property_value = {
        'Fn::If' => [
          'SomeCond',
          {
            'Description'=>'New',
            'GenerateSecretString'=>{
              'SecretStringTemplate' => '{"username": "test-user"}'
            }
          },
          {
            'Description'=>'Restore',
            'SecretString'=> {'Ref'=> 'RestoreSecretString'},
            'Moo' => {'Fn::If'=> %w(Cond2 Cow Dog)}
          }
        ]
      }
      conditions = {'SomeCond'=>false,'Cond2'=>false}
      actual_evaluation = ExpressionEvaluator.new.evaluate(property_value, conditions)
      expected_evaluation = {
        'Description'=>'Restore',
        'SecretString'=> {'Ref'=> 'RestoreSecretString'},
        'Moo'=>'Dog'
      }
      expect(actual_evaluation).to eq expected_evaluation
    end
  end
end