# This has test coverage in the models that it is included into (Activity, Licence, Sector)

module PublicId
  def self.included(klass)
    klass.instance_eval do
      field :public_id, :type => Integer
      index({ public_id: 1 }, { unique: true })

      before_save :set_public_id
    end

    klass.extend(ClassMethods)
  end

  private
  def set_public_id
    if self.public_id.nil?
      counters = Mongoid::Sessions.default["counters"]
      counter = counters.find(
        '_id' => self.class.name
      ).modify(
        {'$inc' => { :count => 1 }},
        :new => true, :upsert => true
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
