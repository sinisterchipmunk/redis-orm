class Redis::ORM
  module Attributes
    def self.included(base)
      base.class_eval do
        extend Redis::ORM::Attributes::ClassMethods
        class_inheritable_hash :model_attributes
        self.model_attributes ||= HashWithIndifferentAccess.new
      end
    end
  
    def attributes
      @attributes ||= model_attributes.dup
    end
  
    def set_unchanged!
      @previous_attributes = attributes.dup
    end

    def attribute_names
      @attribute_names ||= attributes.keys
    end
  
    def attributes=(changed_attributes)
      changed_attributes.each do |key, value|
        send("#{key}=", value)
      end
    end
  
    def previous_attributes
      # note we do NOT assign here, this is because #changed?
      # and #new_record? rely on @previous_attributes to be nil
      @previous_attributes || attributes.dup
    end

    def new_record?
      @previous_attributes.nil?
    end
  
    def changed?
      new_record? || attributes != @previous_attributes
    end
    
    module ClassMethods
      def attribute_names
        model_attributes.keys
      end

      def attribute(key, default_value = nil)
        model_attributes.merge!({key => default_value})

        define_method key do
          attributes[key]
        end

        define_method "#{key}=" do |value|
          if value != attributes[key]
            attributes[key] = value
          else
            value
          end
        end
      end
    end
  end
end
