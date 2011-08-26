module Redis::Actions::Saving
  def self.included(base)
    base.class_eval do
      define_model_callbacks :save
      class_inheritable_array :within_save_blocks
      self.within_save_blocks ||= []
      extend Redis::Actions::Saving::ClassMethods
    end
  end
  
  def save
    if valid?
      define_id if id.nil?
      run_callbacks(:save) do
        transaction do
          within_save_blocks.each do |block_or_method|
            if block_or_method.kind_of?(String) || block_or_method.kind_of?(Symbol)
              send block_or_method
            else
              block_or_method.call self
            end
          end
          connection.set(id, serializer.dump(attributes))
        end
      end
      set_unchanged!
      true
    else
      false
    end
  end
  
  def save!
    raise "Record was not saved: #{errors.full_messages}" unless save
  end
  
  def define_id
    self.id = File.join(model_name, connection.incr("__uniq__").to_s)
  end

  module ClassMethods
    def within_save_block(method_name = nil, &block)
      within_save_blocks << method_name if method_name
      within_save_blocks << block       if block_given?
    end
  end
end
