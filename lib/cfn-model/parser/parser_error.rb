class ParserError < RuntimeError
  attr_accessor :errors

  def initialize(message, validation_errors=nil)
    super(message)
    @message = message
    @errors = validation_errors
  end

  def to_s
    "#{@message}#{@errors.nil? ? '' : ':'}#{@errors.to_s}"
  end
end