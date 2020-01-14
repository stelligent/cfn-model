class ExpressionEvaluator
  FN_IF = 'Fn::If'

  ##
  # {'Fn::If'=>[Condition,X,Y]} returns X if conditions doesn't include Condition, otherwise it return X or Y depending
  #
  # Other than Fn::If, it just returns the value itself
  def evaluate(expression, conditions)
    if if_condition?(expression)
      outcome(expression, conditions)
    else
      expression
    end
  end

  private

  def outcome(expression, conditions)
    if if_condition?(expression)
      if_expression = expression[FN_IF]
      condition_name = if_expression[0]
      if conditions[condition_name]
        outcome(if_expression[1], conditions)
      else
        outcome(if_expression[2], conditions)
      end
    elsif expression.is_a?(Hash) # plain dict
      expression.each do |k,v|
        expression[k] = outcome(v, conditions)
      end
    else
      expression
    end
  end

  def if_condition?(property_value)
    property_value.is_a?(Hash) && property_value.key?(FN_IF) && property_value.size == 1
  end
end