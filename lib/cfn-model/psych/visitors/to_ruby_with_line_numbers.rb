class ToRubyWithLineNumbers < Psych::Visitors::ToRuby
  def revive_hash hash, o
    o.children.each_slice(2) { |k,v|
      key = accept(k)
      val = accept(v)

      # This is the important bit. If the value is a scalar,
      # we replace it with the desired hash.
      if v.is_a?(::Psych::Nodes::Scalar)
        val = { "value" => val, "line" => v.start_line + 1} # line is 0 based, so + 1
      end

      hash[key] = val
    }
    hash
  end
end
