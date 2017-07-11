require_relative 'model_element'

##
# This is the base class for a model element where we aren't anticipating
# a schema or doing any fancier post-processing to think the element up
# with other elements or wrap properties into higher-level objects
#
class DynamicModelElement < ModelElement
  ##
  # Treat any missing method as an instance variable get/set
  #
  # This will allow arbitrary elements in Resource/Properties definitions
  # to map to instance variables without having to anticipate them in a schema
  def method_missing(method_name, *args)
    if method_name =~ /^(\w+)=$/
      instance_variable_set "@#{$1}", args[0]
    else
      instance_variable_get "@#{method_name}"
    end
  end
end