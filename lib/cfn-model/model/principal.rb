# frozen_string_literal: true

class Principal
  def self.wildcard?(principal)
    if principal.is_a? String
      asterisk? principal
    elsif principal.is_a? Hash
      # if new principal types arrive, let's not tie ourselves down - the * is still likely the thing to look for
      # unless %w(AWS FederatedUser CanonicalUser Service).include?(principal.keys.first)
      #   raise "whacky principal key: #{principal}"
      # end

      has_wildcard = false
      principal.values.each do |principal_value|
        if principal_value.is_a? String
          has_wildcard ||= asterisk? principal_value
        elsif principal_value.is_a? Array
          wildcard_principal = principal_value.find { |principal_iter| principal_iter =~ /\*/ }
          has_wildcard ||= !wildcard_principal.nil?
        end
      end
      has_wildcard
    elsif principal.nil?
      false
    else
      # array? not legal?
      raise "whacky principal not string or hash: #{principal}"
    end
  end

  private_class_method def self.asterisk?(string)
    !(string =~ /\*/).nil?
  end
end
