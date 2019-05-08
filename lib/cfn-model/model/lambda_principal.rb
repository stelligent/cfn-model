class LambdaPrincipal
  def self.wildcard?(principal)
    if principal.is_a? String
      return has_asterisk principal
    else
      false
    end
  end

  private

  def self.has_asterisk(string)
    !(string =~ /\*/).nil?
  end
end
