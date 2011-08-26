module Redis::Actions::Finding
  def self.included(base)
    base.send :extend, Redis::ORM::Finding::ClassMethods
  end
  
  module ClassMethods
    def find(id)
      data = connection.get(id)
      if data
        klass_name = id.split(/\//)[0]
        klass = (klass_name.camelize.constantize rescue self)
        instance = klass.new(serializer.load(data))
        instance.set_unchanged!
        instance
      else
        nil
      end
    end
  
    def all
      connection.hgetall(File.join(model_name, "ids")).collect do |id|
        find(id.first)
      end
    end
  end
end
