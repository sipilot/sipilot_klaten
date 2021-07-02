class SubmissionFile < ApplicationRecord
  belongs_to :submission, optional: true
  has_one_attached :image

  belongs_to :submissionable, polymorphic: true

  enum file_type: {
    'measuring_letter' => 1,
    'land_book' => 2,
    'id_number' => 3,
    'authority_letter' => 4,
    'proof_of_alas' => 5,
    'location_description' => 6
  }
end
