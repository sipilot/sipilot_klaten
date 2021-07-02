class ShpBuilder
  def self.build_shp(type, data, file_name)
    generate_csv_shp(data, file_name) if type == 'sipilot'

    p '------====== PYTHON CREATE SHP ======------'
    p `python3 lib/python/create_shapefile.py "#{file_name}"`
    p '------====== *** ======------'

    zip_path = ShpBuilder.create_zip_file(file_name)
    send_data(zip_path, type: 'application/zip', filename: "#{file_name}.zip")
  end

  def self.generate_csv_shp(submissions, file_name)
    CSV.open("lib/python/#{file_name}.csv", 'wb') do |csv|
      csv << [
        'Nama Pendaftar',
        'Bertindak Atas',
        'Nama Lengkap (Sesuai Sertipikat)',
        'Nomor Hak',
        'Jenis Hak',
        'Lattitude',
        'Longitude',
        'Alamat Tanah',
        'Kecamatan',
        'Desa'
      ]
      submissions.each do |submission|
      next if (
        submission.on_behalf.nil? || submission.on_behalf.empty? ||
        submission.lattitude.nil? || submission.lattitude.empty? ||
        submission.longitude.nil? || submission.longitude.empty? ||
        submission.fullname.nil? || submission.fullname.empty? ||
        submission.hak_number.nil? || submission.hak_number.empty? ||
        submission.land_address.nil? || submission.land_address.empty?
      )

      csv << [
        submission.on_behalf,
        submission.act_for,
        submission.fullname,
        submission.hak_number,
        submission.hak_name,
        submission.lattitude,
        submission.longitude,
        submission.land_address,
        submission.sub_district_name,
        submission.village_name
      ]
      end
      p '=== create shp csv'
    end
  end

  def self.generate_csv_shp_intip(submissions, file_name)
    CSV.open("lib/python/#{file_name}.csv", 'wb') do |csv|
      csv << [
        'NUI',
        'NIB',
        'Nama Instansi',
        'Lattitude',
        'Longitude',
        'Alamat Tanah'
      ]
      submissions.each do |submission|
      next if (
        submission.nui.nil? || submission.nui.empty? ||
        submission.nib.nil? || submission.nib.empty? ||
        submission.name.nil? || submission.name.empty? ||
        submission.lattitude.nil? || submission.lattitude.empty? ||
        submission.longitude.nil? || submission.longitude.empty? ||
        submission.land_address.nil? || submission.land_address.empty?
      )

      csv << [
        "'#{submission.nui}",
        "'#{submission.nib}",
        submission.name,
        submission.lattitude,
        submission.longitude,
        submission.land_address
      ]
      end
      p '=== create shp csv intip ==='
    end
  end

  def self.generate_csv_shp_gps(submissions, file_name)
    CSV.open("lib/python/#{file_name}.csv", 'wb') do |csv|
      csv << [
        'Nomor Hak',
        'Nama Pendaftar',
        'Status Sertipikat',
        'Jenis Hak',
        'Lattitude',
        'Longitude',
        'Alamat Tanah',
        'Kecamatan',
        'Desa'
      ]
      submissions.each do |submission|
      next if (
        submission.hak_number.nil? || submission.hak_number.empty? ||
        submission.fullname.nil? || submission.fullname.empty? ||
        submission.certificate_status.nil? || submission.certificate_status.empty? ||
        submission.hak_name.nil? || submission.hak_name.empty? ||
        submission.lattitude.nil? || submission.lattitude.empty? ||
        submission.longitude.nil? || submission.longitude.empty? ||
        submission.land_address.nil? || submission.land_address.empty? ||
        submission.workspace_id.nil?
      )

      csv << [
        submission.hak_number,
        submission.fullname,
        submission.certificate_status,
        submission.hak_name,
        submission.lattitude,
        submission.longitude,
        submission.land_address,
        submission.sub_district_name,
        submission.village_name
      ]
      end
      p '=== create shp csv gps ==='
    end
  end

  def self.create_zip_file(file_name)
    input_filenames = [
      "#{file_name}.cpg",
      "#{file_name}.dbf",
      "#{file_name}.prj",
      "#{file_name}.shp",
      "#{file_name}.shx"
    ]
    folder = Rails.root
    temp_file = Tempfile.new("#{file_name}.zip")
    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip_file|
      input_filenames.each do |filename|
        zip_file.add(filename, File.join(folder, filename))
      end
    end

    # Remove created file
    File.delete("#{Rails.root}/lib/python/#{file_name}.csv")
    input_filenames.each { |file| File.delete(Rails.root + file) if File.exist?(Rails.root + file) }

    # return csv path
    File.read(temp_file.path)
  end
end
