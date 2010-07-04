require 'XibDiffObjectComparison'

include XibDiffObjectComparison

module XibDiffXibComparison
  def compare_classes(*c)
    XibDiffLogger.push(c[0]['class'])
    compare_generic( c[0], c[1], nil )
    XibDiffLogger.pop
  end

  def compare_class_dicts(*class_dict)
    in_a_and_b = []
    class_dict[0].each_pair do |key,value|
      # search for class 'key' in the second hash
      if class_dict[1][key].nil?
        XibDiffLogger.push key
        XibDiffLogger.log "deleted."
        XibDiffLogger.pop
      else
        in_a_and_b << key
        compare_classes(value, class_dict[1][key])
      end
    end

    class_dict[1].each_pair do |k,v|
      if !(in_a_and_b.include? k)
        XibDiffLogger.push k
        preamble = "added => "
        XibDiffLogger.log "#{preamble}#{v.to_pretty_str(" " * XibDiffLogger.msg(preamble).length)}"
        XibDiffLogger.pop
      end
    end
  end

  def compare_hierarchy_arrays(*hierarchy_array)
    in_a_and_b = []
    hierarchy_array[0].each do |item|
      XibDiffLogger.push item['label']
      # search for object named the same in the other dict
      hierarchy_array[1].each do |other_item|
        if other_item['label'] == item['label']
          in_a_and_b << item['label']

          # now compare the two
          compare_generic(item, other_item, :name_key => 'label', :ignore_keys => ['object-id'])
        end
      end

      # Check if not found
      if in_a_and_b.last != item['label']
        XibDiffLogger.log "deleted."
      end
      XibDiffLogger.pop
    end

    # check for the missing ones
    hierarchy_array[1].each do |item|
      if !(in_a_and_b.include? item['label'])
        XibDiffLogger.push item['label']
        preamble = "added => "
        XibDiffLogger.log "#{preamble}#{item.to_pretty_str(" " * XibDiffLogger.msg(preamble).length, :ignore_keys => ['object-id'])}"
        XibDiffLogger.pop
      end
    end
  end

  def dict_with_path_to_object_id(hierarchy_array)
    dict = {}
    stack = [ { :obj => hierarchy_array, :path => [] } ]

    while not stack.empty?
      top = stack.pop
      obj = top[:obj]
      path = top[:path]
      if obj.class == Array
        obj.each_with_index do |e,i|
          obj_name  = i.to_s
          obj_name += ":#{e['label']}" if e['label']
          stack << { :obj => e, :path => (Array.new(path) << obj_name) }
        end
      elsif obj.class == Hash
        obj_path  = path.join('/')
        obj_path += ":#{obj['label']}" if obj['label']
        dict[obj_path] = obj['object-id'] if obj['object-id']
        obj.each_pair do |k,v|
          stack << { :obj => v, :path => Array.new(path) } if v.class == Array and k == 'children'
          stack << { :obj => v, :path => (Array.new(path) << k) } if k != 'children' and ( v.class == Array or v.class == Hash )
        end
      end
    end
    
    dict
  end

  def compare_object_arrays(*params)
    a_dict = params[0]
    a_objs = params[1]
    b_dict = params[2]
    b_objs = params[3]
    
    a_keys = a_dict.keys.sort
    b_keys = b_dict.keys.sort

    a_idx = b_idx = 0
    while a_idx < a_keys.length or b_idx < b_keys.length
      a_key = a_keys[a_idx]
      b_key = b_keys[b_idx]

      if ( a_key and b_key and (a_key < b_key) ) or ( a_key and b_key.nil? )
        # Removed object
        XibDiffLogger.push a_key
        XibDiffLogger.log "deleted."
        XibDiffLogger.pop

        a_idx += 1
      elsif ( a_key and b_key and (a_key > b_key) ) or ( a_key.nil? and b_key )
        # Added object
        XibDiffLogger.push b_key
        preamble = "added => "
        XibDiffLogger.log "#{preamble}#{b_objs[b_dict[b_key].to_s].to_pretty_str(" " * XibDiffLogger.msg(preamble).length )}"
        XibDiffLogger.pop

        b_idx += 1
      else # a_key and b_key and a_key == b_key
        XibDiffLogger.push a_key # or b_key, doesn't matter
        compare_generic(a_objs[a_dict[a_key].to_s], b_objs[b_dict[b_key].to_s])
        XibDiffLogger.pop

        a_idx += 1
        b_idx += 1
      end
    end
  end

  def connection_map_for_connection_array(dict, conns)
    map = {}
    conns.each_pair do |k,v|
      key  = "#{dict[v['source-id']]} => #{dict[v['destination-id']]} #{v['type']}"
      key += " #{v['label']}"                   if v['type'] == 'IBCocoaOutletConnection' or v['type'] == 'IBCocoaActionConnection'
      key += " #{v['binding']}:#{v['keypath']}" if v['type'] == 'IBBindingConnection'
      value = k

      map[key] = value
    end
    map
  end

  def compare_connection_arrays(*params)
    a_dict  = params[0]
    a_conns = params[1]
    b_dict  = params[2]
    b_conns = params[3]

    # build connection map array
    a_map = connection_map_for_connection_array(a_dict, a_conns)
    b_map = connection_map_for_connection_array(b_dict, b_conns)

    a_keys = a_map.keys.sort
    b_keys = b_map.keys.sort

    a_idx = b_idx = 0
    while a_idx < a_keys.length or b_idx < b_keys.length
      a_key = a_keys[a_idx]
      b_key = b_keys[b_idx]

      if ( a_key and b_key and (a_key < b_key) ) or ( a_key and b_key.nil? )
        # Removed object
        XibDiffLogger.push a_key
        XibDiffLogger.log "deleted."
        XibDiffLogger.pop

        a_idx += 1
      elsif ( a_key and b_key and (a_key > b_key) ) or ( a_key.nil? and b_key )
        # Added object
        XibDiffLogger.push b_key
        preamble = "added => "
        XibDiffLogger.log "#{preamble}#{b_conns[b_map[b_key].to_s].to_pretty_str(" " * XibDiffLogger.msg(preamble).length )}"
        XibDiffLogger.pop

        b_idx += 1
      else # a_key and b_key and a_key == b_key
        XibDiffLogger.push a_key # or b_key, doesn't matter
        compare_generic(a_conns[a_map[a_key].to_s], b_conns[b_map[b_key].to_s])
        XibDiffLogger.pop

        a_idx += 1
        b_idx += 1
      end
    end
  end
end
