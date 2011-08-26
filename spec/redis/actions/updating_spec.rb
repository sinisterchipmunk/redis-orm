require 'spec_helper'

describe Redis::Actions::Updating do
  include RedisHelper

  orm_class { attribute :number }
  
  it "should fire update callbacks once, and create callbacks once" do
    before = { :create => 0, :update => 0, :save => 0 }
    after = { :create => 0, :update => 0, :save => 0 }
    orm_class do
      before_save { before[:save] += 1 }
      after_save { after[:save] += 1 }
      before_create { before[:create] += 1 }
      after_create { after[:create] += 1 }
      before_update { before[:update] += 1 }
      after_update { after[:update] += 1 }
    end
    
    orm = orm_class.new
    orm.save
    orm.number = 2
    orm.save
    
    before[:save].should == 2
    after[:save].should == 2
    before[:create].should == 1
    before[:update].should == 1
    after[:create].should == 1
    after[:update].should == 1
  end
end
