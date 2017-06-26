class ParserError < RuntimeError
  def initialize(message)
    super(message)
  end
end