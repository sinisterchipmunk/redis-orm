require 'redis'

class Redis
  autoload :ORM, 'redis/orm'
  
  @@connection = nil
  class << self
    def connection
      @@connection ||= Redis.new(:host => host, :port => port)
    end

    def connection=(redis)
      @@connection = redis
    end

    def host
      @host ||= 'localhost'
    end

    def port
      @port ||= 6379
    end

    def host=(a)
      @host = a
    end

    def port=(a)
      @port = a
    end
  end
end
