require 'google/cloud/firestore'

class FirestoreClient
  attr_accessor :interests

  def initialize
    project_root = File.dirname(File.absolute_path(__FILE__))

    Google::Cloud::Firestore.configure do |config|
      config.project_id  = ENV["FIRESTORE_PROJECT"]
      config.credentials = project_root + ENV["FIRESTORE_CREDENTIALS"]
    end

    @firestore = Google::Cloud::Firestore.new
    fetch_data('interests/PxX0eIvZnNBeTjbGiGLY')
  end

  def fetch_data(document)
    response   = @firestore.doc(document).get
    @interests = response[:interests]
  end

  def write_data(document, field, data)
    ref = @firestore.doc(document)
    ref.set({ "#{field.to_sym}": data })
    fetch_data('interests/PxX0eIvZnNBeTjbGiGLY')
  end
end
