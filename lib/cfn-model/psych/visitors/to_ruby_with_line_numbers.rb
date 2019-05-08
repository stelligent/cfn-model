class ToRubyWithLineNumbers < Psych::Visitors::ToRuby
  def revive_hash hash, o
    o.children.each_slice(2) { |k,v|
      key = accept(k)
      val = accept(v)

      # Supporting various versions of psych
      line = v.respond_to?(:start_line) ? v.start_line + 1 : v.line

      # This is the important bit. If the value is a scalar,
      # we replace it with the desired hash.
      if v.is_a?(::Psych::Nodes::Scalar) && key == 'Type'
        val = { "value" => val, "line" => line}
      end

      hash[key] = val
    }
    hash
  end
end
