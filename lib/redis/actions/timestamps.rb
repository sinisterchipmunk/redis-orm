module Redis::Actions::Timestamps
  def updated_at_timestamp
    self.updated_at = Time.now
  end
  
  def created_at_timestamp
    self.created_at ||= Time.now
  end
  
  def self.included(base)
    base.instance_eval do
      attribute :created_at
      attribute :updated_at
      
      before_save   :updated_at_timestamp
      before_create :created_at_timestamp
    end
  end
end
