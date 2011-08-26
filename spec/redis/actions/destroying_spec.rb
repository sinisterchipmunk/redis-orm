require 'spec_helper'

describe Redis::Actions::Destroying do
  include RedisHelper

  context "with several pre-existing records" do
    orm_class { attribute :random }
    
    before(:each) do
      10.times { |i| orm_class.new(:random => i).save! }
    end
    
    it "should destroy all of them" do
      orm_class.destroy_all
      orm_class.all.length.should == 0
    end
    
    it "should fire destroy callbacks for all of them" do
      before, after = 0, 0
      orm_class { before_destroy { before += 1 }; after_destroy { after += 1 } }
      orm_class.destroy_all
      
      before.should == 10
      after.should == 10
    end
  end
end
