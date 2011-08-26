module Redis::Validations::Uniqueness
  def uniqueness_id(attribute_name)
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
          if id_in_use = connection.hget(record.uniqueness_id(name), record.send(name))
            if id_in_use != record.id
              record.errors.add(name, "must be unique")
            end
          end
        end
      end
      
      within_save_block do |record|
        record.unique_fields.each do |name|
          connection.hdel(record.uniqueness_id(name), record.previous_attributes[name])
          connection.hset(record.uniqueness_id(name), record.send(name), record.id)
        end
      end
      
      within_destroy_block do |record|
        record.unique_fields.each do |name|
          connection.hdel(record.uniqueness_id(name), record.send(name))
        end
      end
    end
  end
end
