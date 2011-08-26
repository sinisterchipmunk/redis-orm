describe Redis::Validations::Uniqueness do
  include RedisHelper
  
  context "without options" do
    orm_class { attribute :name; validates_uniqueness_of :name }
    subject   { orm_class.new }
    
    it "should validate" do
      subject.name = "one"
      subject.save!
      
      other = orm_class.new
      other.name = "one"
      other.should_not be_valid
    end

    it "should not reject its own values" do
      subject.name = "one"
      subject.save!
      subject.should be_valid
    end
    
    it "should not leave keys in use when they change" do
      subject.name = "one"
      subject.save!
      subject.name = "two"
      subject.save!
      
      orm_class.new(:name => "one").should be_valid
    end
  end
end
