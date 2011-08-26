module Redis::Validations
  autoload :Uniqueness, "redis/validations/uniqueness"

  def self.included(base)
    base.class_eval do
      include Redis::Validations::Uniqueness
    end
  end
end
