# This has test coverage in the models that it is included into (Activity, Licence, Sector)

module PublicId
  def self.included(klass)
    klass.instance_eval do
      field :public_id, :type => Integer
      index :public_id, :unique => true

      before_save :set_public_id
    end

    klass.extend(ClassMethods)
  end

  private
  def set_public_id
    if self.public_id.nil?
      counter = Mongoid.database["counters"].find_and_modify(
          :query  => {:_id  => self.class.name},
          :update => {:$inc => {:count => 1}},
          :new    => true,
          :upsert => true
      )["count"]
      self.public_id = counter
    end
  end

  module ClassMethods
    def find_by_public_id(public_id)
      where(public_id: public_id).first
    end
  end
end