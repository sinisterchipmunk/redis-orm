class Redis
  module Actions
    autoload :Finding,    "redis/actions/finding"
    autoload :Destroying, "redis/actions/destroying"
    autoload :Saving,     "redis/actions/saving"
    autoload :Updating,   "redis/actions/updating"
    autoload :Creating,   "redis/actions/creating"
    autoload :Timestamps, "redis/actions/timestamps"
    
    def self.included(base)
      base.class_eval do
        include Redis::Actions::Finding
        include Redis::Actions::Destroying
        include Redis::Actions::Saving
        include Redis::Actions::Updating
        include Redis::Actions::Creating
        include Redis::Actions::Timestamps
      end
    end
  end
end
