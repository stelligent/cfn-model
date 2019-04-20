# frozen_string_literal: true

class LambdaPrincipal
  def self.wildcard?(principal)
    if principal.is_a? String
      asterisk? principal
    else
      false
    end
  end

  private_class_method def self.asterisk?(string)
    !(string =~ /\*/).nil?
  end
end
