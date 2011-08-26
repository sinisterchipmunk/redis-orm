require 'spec_helper'

describe Redis::Actions::Creating do
  include RedisHelper

  orm_class { attribute :number }
  
  it "should fire callbacks" do
    before, after = 0, 0
    orm_class { before_create { before += 1 }; after_create { after += 1 } }
    
    orm_class.create!
    before.should == 1
    after.should == 1
  end
  
  it "should create and return the record" do
    record = orm_class.create(:number => 1)
    record.should be_kind_of(orm_class)
    
    record.should_not be_new_record
    record.should_not be_changed
  end

  it "should create! and return the record" do
    record = orm_class.create!(:number => 1)
    record.should be_kind_of(orm_class)
    
    record.should_not be_new_record
    record.should_not be_changed
  end
end
