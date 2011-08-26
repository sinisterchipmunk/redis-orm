module Redis::Validations::Uniqueness
  def uniqueness_key(attribute_name)
    File.join(model_name, attribute_name.to_s.pluralize)
  end

  def self.included(base)
    base.class_eval do
      class_inheritable_array :unique_fields
      self.unique_fields ||= []
      
      class << self
        def validates_uniqueness_of(field)
          unique_fields << field
        end
      end
      
      validate do |record|
        record.unique_fields.each do |name|
          if key_in_use = connection.hget(record.uniqueness_key(name), record.send(name))
            if key_in_use != record.key
              record.errors.add(name, "must be unique")
            end
          end
        end
      end
      
      within_save_block do |record|
        record.unique_fields.each do |name|
          connection.hdel(record.uniqueness_key(name), record.previous_attributes[name])
          connection.hset(record.uniqueness_key(name), record.send(name), record.key)
        end
      end
      
      within_destroy_block do |record|
        record.unique_fields.each do |name|
          connection.hdel(record.uniqueness_key(name), record.send(name))
        end
      end
    end
  end
end
