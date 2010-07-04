module XibDiffObjectComparison
  def compare_generic(a,b,var=nil)
    if a.class != b.class
      XibDiffLogger.log "items have different classes: a:#{a.class}  b:#{b.class}"
    elsif a.class == Hash
      compare_generic_dicts(a,b,var)
    elsif a.class == Array
      compare_generic_arrays(a,b,var)
    else
      XibDiffLogger.log "items differ: a:#{a}  b:#{b}" unless a == b
    end
  end
  
  def compare_generic_arrays(a,b,var=nil)
    a_idxs = (0..a.length-1).to_a
    b_idxs = (0..b.length-1).to_a
  
    a_idxs.each do |a_idx|
      obj_name  = a_idx.to_s
      obj_name += ":#{a[a_idx][var[:name_key]]}" if var[:name_key] and not a[a_idx][var[:name_key]].nil?
      XibDiffLogger.push obj_name
      min_dist   = 0
      best_match = -1
  
      b_idxs.each do |b_idx|
        dist = a[a_idx].distance_to(b[b_idx],var)
        if dist == 0 # a[a_idx] == b[b_idx]
          min_dist   = 0
          best_match = b_idx
          break
        elsif best_match == -1 || dist < min_dist
          best_match = b_idx
          min_dist   = dist
        end
      end
  
      if best_match == -1
        XibDiffLogger.log "removed"
      else
        b_idxs.delete best_match
  
        if a_idx != best_match
          XibDiffLogger.log "moved to position #{best_match}"
        end
  
        if min_dist > 0
          compare_generic(a[a_idx],b[best_match],var)
        end
      end
      XibDiffLogger.pop
    end
  
    b_idxs.each do |b_idx|
      preamble = "added => "
      XibDiffLogger.log "#{preamble}#{b[b_idx].to_pretty_str(" " * XibDiffLogger.XibDiffLogger.msg(preamble).length,var)}"
    end
  end
  
  def compare_generic_dicts(a,b,var=nil)
    # Pre: a.class == Hash, b.class == Hash
    in_a_and_b = []
    # for each key on dict a
    a.each_pair do |k,v|
      # skip items on ignored list
      next if var and var[:ignore_keys] and var[:ignore_keys].include? k
  
      # check if it's in b
      if b[k].nil?
        XibDiffLogger.log "removed '#{k}'"
      else
        in_a_and_b << b[k] # add to intersection list
  
        XibDiffLogger.push(k)
        compare_generic(v,b[k],var) # recursive compare
        XibDiffLogger.pop
      end
    end
  
    # check if missing key in b
    b.each_pair do |k,v|
      # skip items on ignored list
      next if var and var[:ignore_keys] and var[:ignore_keys].include? k
  
      if !in_a_and_b.include? v
        preamble = "added '#{k}' => "
        XibDiffLogger.log "#{preamble}#{v.to_pretty_str(" " * XibDiffLogger.msg(preamble).length,var)}" if v.class == Hash
        XibDiffLogger.log "#{preamble}#{v}#{" " * XibDiffLogger.msg(preamble).length}"                  if v.class != Hash
      end
    end
  end
end
