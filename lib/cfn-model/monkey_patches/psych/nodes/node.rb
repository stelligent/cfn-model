# Psych's first step is to parse the Yaml into an AST of Node objects
# so we open the Node class and add a way to track the line.
class Psych::Nodes::Node
  attr_accessor :line
end
