# This has test coverage in the models that it is included into (Activity, Licence, Sector)

module PublicId
  def self.included(klass)
    klass.instance_eval do
      field :public_id, type: Integer
      index({ public_id: 1 }, unique: true)

      before_save :set_public_id
    end

    klass.extend(ClassMethods)
  end

private

  def set_public_id
    if public_id.nil?
      counters = Mongoid::Clients.default["counters"]
      counter = counters.find_one_and_update(
        {
          "_id" => self.class.name,
        },
        {
          "$inc" => { count: 1 },
        },
        return_document: :after,
        upsert: true,
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
