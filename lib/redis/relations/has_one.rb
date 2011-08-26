module Redis::Relations::HasOne
  def has_one_references
    @has_one_references ||= {}
  end
  
  def set_has_one_reference(relation_name, value)
    has_one_references[relation_name] = value
  end
  
  def get_has_one_reference(relation_name)
    if has_one_references.key?(relation_name)
      has_one_references[relation_name]
    else
      result = self.class.find(connection.hget(has_one_relation_id(relation_name), id))
      has_one_references[relation_name] = result
    end
  end
  
  def has_one_relation_id(name)
    File.join("references", has_one_relations[name][:relation].to_s)
  end
  
  def save_has_one_references
    has_one_references.each do |relation_name, reference|
      if reference
        connection.hset(has_one_relation_id(relation_name), id, reference.id)
        connection.hset(has_one_relation_id(relation_name), reference.id, id)
      end
    end
  end
  
  def self.included(base)
    base.class_eval do
      add_relation :has_one
      
      class << self
        def has_one(relation_name, options = {})
          has_one_relations[relation_name] = options.reverse_merge({ :relation => relation_name })
          
          define_method relation_name do
            get_has_one_reference(relation_name)
          end
          
          define_method "#{relation_name}=" do |a|
            set_has_one_reference(relation_name, a)
          end
        end
      end
    end
  end
end
