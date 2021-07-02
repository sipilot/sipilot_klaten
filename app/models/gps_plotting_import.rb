class GpsPlottingImport
  extend ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :user, :workspace

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_gps.map(&:valid?).all?
      imported_gps.each(&:save!)
      true
    else
      imported_gps.each_with_index do |gps, index|
        gps.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_gps
    @imported_gps ||= load_imported_gps
  end

  def load_imported_gps
    added_value = {
      'user_id' => user.id,
      'workspace_id' => workspace.id,
      'village_id' => workspace.village.id,
      'sub_district_id' => workspace.sub_district.id
    }

    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    hak_types = HakType.all.as_json
    new_header = set_header(header)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[new_header, spreadsheet.row(i)].transpose]
      records = row.to_h.update(row.to_h) { |key, value| value.to_s.strip }
      hak_type_id = hak_types.select { |data| data['name'] == records['hak_type_id'] }.first['id']
      new_records = records.update(records) { |key, value| key == 'hak_type_id' ? hak_type_id : value }
      final_records = new_records.merge! added_value

      # save to db
      gps = GpsPlotting.new
      gps.assign_attributes(final_records)
      gps
    end
  end

  def set_header(header)
    header.map do |h|
      if h == 'Nomor Hak'
        'hak_number'
      elsif h == 'Jenis Hak'
        'hak_type_id'
      elsif h == 'Bertindak Atas'
        'act_for'
      elsif h == 'Nama Pendaftar'
        'on_behalf'
      elsif h == 'Nama Lengkap (Sesuai Sertipikat)'
        'fullname'
      elsif h == 'Lattitude'
        'lattitude'
      elsif h == 'Longitude'
        'longitude'
      else
        h
      end
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end