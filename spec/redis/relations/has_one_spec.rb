require 'spec_helper'

describe Redis::Relations::HasOne do
  include RedisHelper
  
  orm_class { has_one :other }
  subject { orm_class.new }
  
  it "should save the relations" do
    other = orm_class.create
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
end
