require 'spec_helper'

describe Redis::Actions::Finding do
  include RedisHelper

  context "with several pre-existing records" do
    orm_class { attribute :random }
    
    before(:each) do
      10.times { |i| orm_class.new(:random => i).save! }
    end
    
    it "should find all of them" do
      all = orm_class.all
      all.length.should == 10
      10.times { |i| all[i].random.should == i }
    end
  end
  
  context "with key not matching known constants" do
    it "should find record with its own class" do
      orm_class.create!(:key => '1234')
      orm_class.find('1234').should be_kind_of(orm_class)
    end
  end
end
