namespace :generate do
    namespace :region_data do
      namespace :sragen do
        namespace :csv do
  
          desc 'Generate .csv region for spesific district.'
  
          # rake generate:region_data:sragen:csv:create_file
          task :create_file do
            puts "Processing create file.."
  
            provinces = CSV.read("#{Rails.root}/db/data/provinces.csv")
            regencies = CSV.read("#{Rails.root}/db/data/regencies.csv")
            districts = CSV.read("#{Rails.root}/db/data/districts.csv")
            villages = CSV.read("#{Rails.root}/db/data/villages.csv")
  
            CSV.open("#{Rails.root}/db/data/region_sragen.csv", 'wb') do |csv|
              regencies.each do |regency|
                regencies_data = []
                regency_id = regency.first
                regency_code = regency.second
                regency_name = regency.last
  
                rowNumber = 0
                if regency_name == 'KABUPATEN SRAGEN'
                  p "regency : #{regency}"
                  districts.each do |district|
                    district_id, district_code, district_name = district.first, district.second, district.last
                    if regency_id == district_code
                      p "district : #{district}"
                      villages.each do |village|
                        village_id, village_code, village_name = village.first, village.second, village.last
                        if district_id == village_code
                          p "village : #{village}"
                          rowNumber += 1
                          csv << [ rowNumber, district_name, village_name ]
                        end
                      end
                    end
                  end
                end
              end
            end
          end
  
          # rake generate:region_data:sragen:csv:seed_file
          task :seed_file do
            sub_districts = CSV.read("#{Rails.root}/db/data/region_sragen.csv")
            sub_districts.each do |value|
              sub_district = value.second
              village = value.third
              sd = ActiveRecord::Relation::SubDistrict.new.find_or_create_by(name: sub_district)
              sd.update(district_id: District.find_by(name: 'KABUPATEN SRAGEN').id)
              ActiveRecord::Relation::Village.find_or_create_by(name: village, sub_district_id: sd.id)
  
              puts "#{sub_district} - #{village}"
              puts '======> SEEDING SUB DISTRICTS SRAGEN <======'
            end
          end
  
        end
      end
    end
  end