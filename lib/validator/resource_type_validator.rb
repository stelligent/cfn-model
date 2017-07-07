class ResourceTypeValidator

  def self.validate(cloudformation_yml)
    hash = YAML.load cloudformation_yml
    if hash == false || hash.nil?
      raise 'yml empty'
    end

    if hash['Resources'].nil? or hash['Resources'].empty?
      raise 'Illegal cfn - no Resources'
    end

    resources = hash['Resources']

    resources.each do |resource_id, resource|
      if resource['Type'].nil?
        raise "Illegal cfn - missing Type: id: #{resource_id}"
      end
    end

    parameters = hash['Parameters']
    unless parameters.nil?
      parameters.each do |parameter_id, parameter|
        if parameter['Type'].nil?
          raise "Illegal cfn - missing Parameter Type: id: #{parameter_id}"
        end
      end
    end

    hash
  end
end