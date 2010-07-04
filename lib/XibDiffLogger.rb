class XibDiffLogger
  @@obj_path = []

  @@separator = '/'

  def self.obj_path
    @@obj_path.join(@@separator)
  end

  def self.msg(msg)
    "#{obj_path}: #{msg}"
  end

  def self.log(msg)
    puts msg(msg)
  end

  def self.push(e)
    @@obj_path << e
  end

  def self.pop
    @@obj_path.pop
  end
end
