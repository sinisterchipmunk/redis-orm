module Redis::Relations
  autoload :BelongsTo, "redis/relations/belongs_to"
  autoload :HasMany,   "redis/relations/has_many"
  autoload :HasOne,    "redis/relations/has_one"
  
  def self.included(base)
    base.class_eval do
      class << self
        def add_relation(name)
          varn = "#{name}_relations"
          class_inheritable_hash varn                       # class_inheritable_hash 'belongs_to_relations'
          send(varn) || send("#{varn}=", {})                # self.belongs_to_relations ||= {}
          within_save_block "save_#{name}_references"       # within_save_block 'save_belongs_to_references'
        end
      end
      
      include Redis::Relations::BelongsTo
      include Redis::Relations::HasMany
      include Redis::Relations::HasOne
    end
  end
end
