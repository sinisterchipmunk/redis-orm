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
    
    orm_class.find(subject.id).other.should be_kind_of(orm_class)
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
