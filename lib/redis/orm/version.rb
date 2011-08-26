class Redis
  class ORM
    module Version
      MAJOR = 0
      MINOR = 0
      PATCH = 2
      PREREL = nil
    
      STRING = PREREL ? [MAJOR, MINOR, PATCH, PREREL].join('.') : [MAJOR, MINOR, PATCH].join('.')
    end
  
    VERSION = Version::STRING
  end
end
