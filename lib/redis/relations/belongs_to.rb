module Redis::Relations::BelongsTo
  def belongs_to_references
    @belongs_to_references ||= {}
  end
  
  def set_belongs_to_reference(name, a)
    belongs_to_references[name] = a
  end
  
  def get_belongs_to_reference(name)
    if belongs_to_references.key?(name)
      belongs_to_references[name]
    else
      result = self.class.find(connection.hget(belongs_to_relation_key(name), key))
      belongs_to_references[name] = result
    end
  end
  
  def belongs_to_relation_key(name)
    File.join("references", belongs_to_relations[name][:relation].to_s)
  end
  
  def save_belongs_to_references
    belongs_to_references.each do |relation_name, reference|
      if reference
        reference = reference.key
      end
      connection.hset(belongs_to_relation_key(relation_name), key, reference)
    end
  end
  
  def self.included(base)
    base.class_eval do
      add_relation :belongs_to
      
      class << self
        def belongs_to(relation_name, options = {})
          belongs_to_relations[relation_name] = options.reverse_merge({ :relation => relation_name })
        
          define_method relation_name do
            get_belongs_to_reference(relation_name)
          end
        
          define_method "#{relation_name}=" do |a|
            set_belongs_to_reference(relation_name, a)
          end
        end
      end
    end
  end
end
