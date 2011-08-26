$:.unshift "./lib"
require 'redis/orm'

class A < Redis::ORM
  attribute :index
  has_many :others
end

a1 = A.new(:index => 1)
a2 = A.new(:index => 2)
a3 = A.new(:index => 3)

a3.save!
a2.save!
a1.others << a2 << a3
a1.save!

p a1.key
p A.find(a1.key), A.find(a1.key).others

puts A.all.collect { |a| a.inspect }

A.destroy_all
