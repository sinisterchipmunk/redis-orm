module Redis::Relations::HasMany
  def has_many_references
    @has_many_references ||= {}
  end
  
  def get_has_many_reference(relation_name)
    if has_many_references.key?(relation_name)
      has_many_references[relation_name]
    else
      result = connection.hget(has_many_relation_id(relation_name), id)
      if result
        result = serializer.load(result)
        if result.respond_to?(:collect)
          result = result.collect { |r| self.class.find(r) }
        else
          result = [find(result)]
        end
      else
        result = []
      end
      has_many_references[relation_name] = result
    end
  end
  
  def save_has_many_references
    has_many_references.each do |relation_name, array|
      array = array.collect { |a| a.id }
      connection.hset(has_many_relation_id(relation_name), id, serializer.dump(array))
      array.each do |aid|
        connection.hset(has_many_relation_id(relation_name), aid, id)
      end
    end
  end
  
  def has_many_relation_id(name)
    File.join("references", has_many_relations[name][:relation].to_s)
  end
  
  def self.included(base)
    base.class_eval do
      add_relation :has_many
      
      class << self
        def has_many(relation_name, options = {})
          has_many_relations[relation_name] = options.reverse_merge({ :relation => relation_name })
        
          define_method relation_name do
            get_has_many_reference(relation_name)
          end
          
          define_method "#{relation_name}=" do |array|
            target = get_has_many_reference(relation_name)
            target.clear
            target.concat array
          end
        end
      end
    end
  end
end
