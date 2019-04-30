# We need to provide a handler that will add the line to the node
# as it is parsed. TreeBuilder is the "usual" handler, that
# creates the AST.
class LineNumberHandler < Psych::TreeBuilder

  # The handler needs access to the parser in order to call mark
  attr_accessor :parser

  # We are only interested in scalars, so here we override
  # the method so that it calls mark and adds the line info
  # to the node.
  def scalar value, anchor, tag, plain, quoted, style
    mark = parser.mark
    s = super
    s.line = mark.line
    s
  end
end
