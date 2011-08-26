require 'spec_helper'

describe Redis::Relations::BelongsTo do
  include RedisHelper
  
  orm_class { belongs_to :other }
  subject { orm_class.new }
  
  it "should save the relation" do
    other = orm_class.new
    other.save!
    subject.other = other
    subject.save!
    
    orm_class.find(subject.key).other.should be_kind_of(orm_class)
  end
  
  it "mass assignment" do
    other = orm_class.new
    other.save!
    subject = orm_class.create!(:other => other)
    subject.other.should be(other)
  end

  it "should save without relatives" do
    subject.save!
  end
end


=begin

class Aye
  has_many bees(, :foreign_key => :aye_id)
end

class Bee
  (attribute :aye_id)
  belongs_to aye
end



# reference built on the relation (foreign_key):
# has_many uses its own name while belongs_to uses
# the reference name

references/ayes
  Aye/1 => [ Bee/1, Bee/2 ]  # has_many stores an array of keys
  Bee/1 => Aye/1             # belongs_to stores a single key
  Bee/2 => Aye/1
  

=end
