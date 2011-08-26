describe Redis::Actions::Timestamps do
  include RedisHelper

  context "when record is created" do
    it "should set created_at and updated_at" do
      instance = orm_class.create!
      instance.created_at.should_not be_blank
      instance.updated_at.should_not be_blank
    end
  end
end
