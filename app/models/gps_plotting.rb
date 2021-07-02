class GpsPlotting < ApplicationRecord
  belongs_to :user
  belongs_to :village
  belongs_to :hak_type, optional: true
  belongs_to :sub_district
  belongs_to :workspace, optional: true
  belongs_to :alas_type, optional: true
  has_many :submission_files, as: :submissionable

  scope :ordered, -> { includes(:sub_district).order('sub_districts.name') }

  enum act_for: {
    'Diri Sendiri' => 1,
    'Kuasa' => 2
  }

  enum certificate_status: {
    'Sudah Sertipikat' => 1,
    'Belum Sertipikat' => 2
  }

  enum status: {
    'proses' => 1,
    'revisi' => 2,
    'selesai' => 3,
    'sudah direvisi' => 4
  }

  validate :hak_number_exist, on: :create

  # ransack
  ransacker :created_at do
    Arel.sql('date(created_at)')
  end

  def sent
    sent_at.strftime('%d-%m-%Y')
  rescue StandardError
    ''
  end

  def hak_type_name
    return '' if certificate_status == 'Belum Sertipikat'

    hak_type.name
  end

  def alas_hak_type_name
    return '' if certificate_status == 'Sudah Sertipikat'

    alas_type.name rescue ''
  end

  def hak_name
    hak_type.name
  end

  def alas_name
    alas_type.name rescue ''
  end

  def village_name
    workspace.village.name
  rescue StandardError
    ''
  end

  def sub_district_name
    workspace.sub_district.name
  rescue StandardError
    ''
  end

  def date
    created_at.strftime('%d %B %Y')
  end

  def api_process_submission_image_update(land_book, measuring_letter, id_number, authority_letter, proof_of_alas, location_description)
    unless location_description.nil?
      submission = self.submission_files.find_by(file_type: 'location_description')
      if submission
        submission.update(image: location_description)
      else
        submission_files.create(file_type: 'location_description', image: location_description)
      end
    end

    unless proof_of_alas.nil?
      submission = self.submission_files.find_by(file_type: 'proof_of_alas')
      if submission
        submission.update(image: proof_of_alas)
      else
        submission_files.create(file_type: 'proof_of_alas', image: proof_of_alas)
      end
    end

    unless authority_letter.nil?
      submission = self.submission_files.find_by(file_type: 'authority_letter')
      if submission
        submission.update(image: authority_letter)
      else
        submission_files.create(file_type: 'authority_letter', image: authority_letter)
      end
    end

    unless id_number.nil?
      submission = self.submission_files.find_by(file_type: 'id_number')
      if submission
        submission.update(image: id_number)
      else
        submission_files.create(file_type: 'id_number', image: id_number)
      end
    end

    unless land_book.nil?
      submission = self.submission_files.find_by(file_type: 'land_book')
      if submission
        submission.update(image: land_book)
      else
        submission_files.create(file_type: 'land_book', image: land_book)
      end
    end

    unless measuring_letter.nil?
      submission = self.submission_files.find_by(file_type: 'measuring_letter')
      if submission
        submission.update(image: measuring_letter)
      else
        submission_files.create(file_type: 'measuring_letter', image: measuring_letter)
      end
    end
  end

  def process_submission_image_update(land_books, measuring_letters, id_number, authority_letter, proof_of_alas, location_description)
    unless location_description.nil?
      submission = self.submission_files.find_by(file_type: 'location_description')
      submission.update(image: location_description) if submission
    end

    unless proof_of_alas.nil?
      submission = self.submission_files.find_by(file_type: 'proof_of_alas')
      submission.update(image: proof_of_alas) if submission
    end

    unless authority_letter.nil?
      submission = self.submission_files.find_by(file_type: 'authority_letter')
      submission.update(image: authority_letter) if submission
    end

    unless id_number.nil?
      submission = self.submission_files.find_by(file_type: 'id_number')
      submission.update(image: id_number) if submission
    end

    unless land_books.nil?
      land_books.each do |lb|
        submission_file = self.submission_files.find_by(file_type: 'land_book', description: lb[0])
        if submission_file
          submission_file.update(image: lb[-1])
        else
          self.submission_files.create(file_type: 'land_book', description: lb[0], image: lb[-1])
        end
      end
    end

    unless measuring_letters.nil?
      measuring_letters.each do |lb|
        submission_file = self.submission_files.find_by(file_type: 'measuring_letter', description: lb[0])
        if submission_file
          submission_file.update(image: lb[-1])
        else
          self.submission_files.create(file_type: 'measuring_letter', description: lb[0], image: lb[-1])
        end
      end
    end
  end

  def process_submission_image_nested(land_books, measuring_letters, id_number, authority_letter, proof_of_alas, location_description)
    self.submission_files.create(image: id_number, file_type: 'id_number', description: 'ktp')
    self.submission_files.create(image: proof_of_alas, file_type: 'proof_of_alas', description: 'proof_of_alas') unless proof_of_alas.nil?
    self.submission_files.create(image: location_description, file_type: 'location_description', description: 'location_description') unless location_description.nil?
    self.submission_files.create(image: authority_letter, file_type: 'authority_letter', description: 'authority_letter') unless authority_letter.nil?

    land_books.each {|key, value| self.submission_files.create(image: value, description: key, file_type: 'land_book')} unless land_books.nil?
    measuring_letters.each {|key, value| self.submission_files.create(image: value, description: key, file_type: 'measuring_letter')} unless measuring_letters.nil?
  end

  def process_submission_update_image_nested(land_books, measuring_letters, id_number, authority_letter, proof_of_alas, location_description)
    self.submission_files.find_by(file_type: 'id_number').update(image: id_number) unless id_number.nil?
    self.submission_files.find_by(file_type: 'proof_of_alas').update(image: proof_of_alas) unless proof_of_alas.nil?
    self.submission_files.find_by(file_type: 'location_description').update(image: location_description) unless location_description.nil?
    self.submission_files.find_by(file_type: 'authority_letter').update(image: authority_letter) unless authority_letter.nil?

    unless land_books.nil?
      land_books.each do |lb|
        submission_file = self.submission_files.find_by(file_type: 'land_book', description: lb[0])
        if submission_file
          submission_file.update(image: lb[-1])
        else
          self.submission_files.create(file_type: 'land_book', description: lb[0], image: lb[-1])
        end
      end
    end

    unless measuring_letters.nil?
      measuring_letters.each do |lb|
        submission_file = self.submission_files.find_by(file_type: 'measuring_letter', description: lb[0])
        if submission_file
          submission_file.update(image: lb[-1])
        else
          self.submission_files.create(file_type: 'measuring_letter', description: lb[0], image: lb[-1])
        end
      end
    end
  end

  def hak_number_exist
    submission = GpsPlotting.find_by(hak_number: self.hak_number, hak_type: self.hak_type)

    return unless submission.present?

    errors.add(:nomor_hak, 'sudah terdaftar pada jenis sertipikat yang anda pilih.')
  end

  def image_measuring_letter
    submission_files.where(file_type: 'measuring_letter')
  rescue StandardError
    nil
  end

  def image_id_number
    submission_files.where(file_type: 'id_number').first.image
  rescue StandardError
    nil
  end

  def image_land_book
    submission_files.where(file_type: 'land_book')
  rescue StandardError
    nil
  end

  def image_alas_hak
    submission_files.where(file_type: 'proof_of_alas').first.image
  rescue StandardError
    nil
  end

  def image_ground_sketch
    submission_files.where(file_type: 'location_description').first.image
  rescue StandardError
    nil
  end

  def image_authority_letter
    submission_files.where(file_type: 'authority_letter').first.image
  rescue StandardError
    nil
  end
end
