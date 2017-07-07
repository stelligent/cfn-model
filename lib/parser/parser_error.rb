class ParserError < RuntimeError
  attr_accessor :errors

  def initialize(message, validation_errors=nil)
    super(message)
    @errors = validation_errors
  end
end