module RedisHelper
  def connection
    @connection ||= Redis.connection
  end
  
  alias redis connection
  
  def self.included(base)
    class << base
      def orm_class(name = "Klass", &block)
        before(:each) { orm_class(name, &block) }
      end
    end
  end
  
  def orm_class(name = "Klass", &block)
    @orm_class ||= begin
      klass = Class.new(Redis::ORM)
      def klass.name; @name; end
      def klass.name=(n); @name = n; end
      klass.name = name;
      klass
    end
    @orm_class.send(:class_eval, &block) if block_given?
    @orm_class
  end
end
