require 'spec_helper'

describe "relation interoperability:" do
  include RedisHelper
  
  describe "belongs_to and has_one" do
    orm_class { has_one :other, :relation => :original; belongs_to :original }
    subject { orm_class.new }

    it "should populate the reverse association" do
      other = orm_class.create
      subject.other = other
      subject.save!

      other.original.should == subject
    end
  end
  
  describe "belongs_to and has_many" do
    orm_class { has_many :others, :relation => :original; belongs_to :original }
    subject { orm_class.new }

    it "should populate the reverse association" do
      other = orm_class.create
      subject.others << other
      subject.save!

      other.original.should == subject
    end
  end
  
  it "should not set callbacks cross subclasses" do
    saved = false
    
    c = Class.new(orm_class) { after_save :saved; define_method(:saved) { saved = true }; class << self; def name; 'c'; end end }
    c2= Class.new(orm_class) { class << self; def name; 'c2'; end end }
    
    c2.new.save!
    saved.should_not be_true
    
    # sanity check
    c.new.save!
    saved.should be_true
  end
end
