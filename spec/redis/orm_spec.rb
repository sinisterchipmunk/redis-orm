require 'spec_helper'

describe Redis::ORM do
  include RedisHelper
  it_should_behave_like "ActiveModel"
  
  it "should have an attributes hash" do
    subject.attributes.should be_kind_of(Hash)
  end
  
  context "with attributes" do
    orm_class { attribute :one, 1 }
    subject { orm_class.new }
    
    it "should set attributes" do
      subject.attributes = { :one => 2 }
      subject.one.should == 2
    end
    
    it "should assign defaults" do
      subject.one.should == 1
    end
    
    context "changing" do
      before(:each) { subject.one = 2 }
      
      it "should be changed" do
        subject.should be_changed
      end
    
      context "and saving" do
        before(:each) { subject.save.should == true }
      
        it "should not be new" do
          subject.should_not be_new_record
        end
      
        it "should not be changed" do
          subject.should_not be_changed
        end
      
        it "should have a id" do
          subject.id.should_not be_nil
        end
      
        it "should be find-able" do
          orm_class.find(subject.id).should == subject
        end
      
        it "should find separate instances" do
          orm_class.find(subject.id).should_not be(subject)
        end
      end
    end
  end
end
