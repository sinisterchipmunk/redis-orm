module Redis::Actions::Creating
  def self.included(base)
    base.send :extend, Redis::Actions::Creating::ClassMethods
    base.define_model_callbacks :create
    base.around_save :create_if_new
  end
  
  def create_if_new
    if new_record?
      run_callbacks(:create) do
        yield
      end
    else
      yield
    end
  end
  
  module ClassMethods
    def create(attributes = {})
      record = new(attributes)
      record.save
      record
    end
    
    def create!(attributes = {})
      record = new(attributes)
      record.save!
      record
    end
  end
end
