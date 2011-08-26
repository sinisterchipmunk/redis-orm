module Redis::Actions::Updating
  def self.included(base)
    base.class_eval do
      base.define_model_callbacks :update
      around_save :update_if_not_new
    end
  end
  
  def update_if_not_new
    if new_record?
      yield
    else
      run_callbacks(:update) do
        yield
      end
    end
  end
end
