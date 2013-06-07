class UserCacheResult
  # PROPERTIES = [:encoding, :records, :maxBatchSize]

  # PROPERTIES.each { |prop|
  #   attr_accessor prop
  # }

  # def initialize(attributes = {})
  #   attributes.each { |key, value|
  #     self.send("#{key}=", value) if PROPERTIES.member? key.to_sym
  #   }
  # end

  # # called when an object is loaded from NSUserDefaults
  # # this is an initializer, so should return `self`
  # def initWithCoder(decoder)
  #   self.init
  #   PROPERTIES.each { |prop|
  #     value = decoder.decodeObjectForKey(prop.to_s)
  #     self.send((prop.to_s + "=").to_s, value) if value
  #   }
  #   self
  # end

  # # called when saving an object to NSUserDefaults
  # def encodeWithCoder(encoder)
  #   PROPERTIES.each { |prop|
  #     encoder.encodeObject(self.send(prop), forKey: prop.to_s)
  #   }
  # end

  # def save
  #   archiveable_self = NSKeyedArchiver.archivedDataWithRootObject(self)
  #   :cache.set_default({jsonResponse: archiveable_self})
  # end

  # def self.load
  #   cache = :cache.get_default rescue nil
  #   return nil unless cache
  #   NSKeyedUnarchiver.unarchiveObjectWithData(cache[:jsonResponse])
  # end
end