require 'spec_helper'

describe Redis::Relations::HasMany do
  include RedisHelper
  
  orm_class { has_many :others }
  subject { orm_class.new }
  
  it "should save the relations" do
    10.times do
      other = orm_class.new
      other.save!
      subject.others << other
    end
    subject.save!
    
    orm_class.find(subject.id).others.should have(10).items
    for i in 0...10
      orm_class.find(subject.id).others[i].should be_kind_of(orm_class)
    end
  end
  
  it "mass assignment" do
    other = orm_class.new
    other.save!
    subject = orm_class.create!(:others => [other])
    subject.others.first.should be(other)
  end

  it "should save without relatives" do
    subject.save!
  end
end
