module DirectModel
  def resources_by_type(direct_model:, resource_type:)
    direct_model['Resources'].select { |_, resource| resource['Type'] == resource_type }
  end
end