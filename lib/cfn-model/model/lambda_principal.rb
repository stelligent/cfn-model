class LambdaPrincipal
  def self.wildcard?(principal)
    if principal.is_a? String
      return has_asterisk principal
    elsif principal.is_a? Integer
      false
    elsif principal.nil?
      false
    else
      #not legal?
      raise "whacky lambda principal not string or hash: #{principal}"
    end
  end

  private

  def self.has_asterisk(string)
    !(string =~ /\*/).nil?
  end
end
