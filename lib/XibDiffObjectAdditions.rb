module ArrayPrettyPrint
  def to_pretty_str(indent,var=nil)
    res = ""
    self.each_with_index do |e,i|
      preamble = "#{i} = "
      res += preamble
      if e.respond_to? 'to_pretty_str'
        res += e.to_pretty_str(indent + " " * preamble.length,var)
      else
        res += e.to_s
      end
      res += "\n" + indent
    end
    res
  end
end

module HashPrettyPrint
  def to_pretty_str(indent,var=nil)
    res = ""
    each_pair do |k,v|
      # ignore certain keys
      next if var and var[:ignore_keys] and var[:ignore_keys].include? k

      preamble = "#{k} = "
      res += preamble
      if v.respond_to? 'to_pretty_str'
        res += v.to_pretty_str(indent + " " * preamble.length,var)
      else
        res += v.to_s
      end
      res += "\n" + indent
    end
    res
  end
end

module DistanceTo
  def distance_to(other,var=nil)
    d = 0 # assume they're equal
    if self.class != other.class
      d += 1000
    elsif self.class == Array
      if self.length != other.length
        d += 100
      else
        self.each_with_index do |e,i|
          d += e.distance_to(other[i],var)
        end
      end
    elsif self.class == Hash
      if self.keys.length != other.keys.length
        d += 50
      elsif self.keys != other.keys
        d += 50
      else
        self.each_pair do |k,v|
          # ignore certain keys
          next if var and var[:ignore_keys] and var[:ignore_keys].include? k

          d += v.distance_to(other[k],var)
        end
      end
    else
      # At this point, self and other should be of the same
      # class, and not an Array nor a Hash
      d += 1 if self.eql? other
    end
    d
  end
end

Object.class_eval do
  include DistanceTo
end

Array.class_eval do
  include ArrayPrettyPrint
end

Hash.class_eval do
  include HashPrettyPrint
end
