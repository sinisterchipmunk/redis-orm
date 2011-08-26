module Redis::Actions::Destroying
  def self.included(base)
    base.class_eval do
      extend Redis::Actions::Destroying::ClassMethods
      define_model_callbacks :destroy
      class_inheritable_array :within_destroy_blocks
      self.within_destroy_blocks ||= []
    end
  end
  
  def destroy
    unless new_record?
      # run_callbacks(:before_destroy)
      run_callbacks(:destroy) do
        transaction do
          connection.del key
          within_destroy_blocks.each do |method_name_or_block|
            if method_name_or_block.kind_of?(String) || method_name_or_block.kind_of?(Symbol)
              send method_name_or_block
            else
              method_name_or_block.call self
            end
          end
        end
      end
    end
  end
  
  module ClassMethods
    def destroy_all
      all.each { |orm| orm.destroy }
    end
    
    def within_destroy_block(method_name = nil, &block)
      within_destroy_blocks << method_name if method_name
      within_destroy_blocks << block       if block_given?
    end
  end
end
