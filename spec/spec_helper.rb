$:.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'redis/orm'

Dir[File.expand_path('support/**/*.rb', File.dirname(__FILE__))].each { |f| require f }

RSpec.configure do |c|
  c.before(:each) do
    Redis.connection.select "redis-orm-testing"
    Redis.connection.flushdb
    Redis::ORM.serializer = YAML
  end
end
