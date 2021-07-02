require 'csv'

# role seeding
roles = [
  'Admin GPS',
  'Super User',
  'Super Admin',
  'Member GPS',
  'Admin Intip',
  'Member Intip',
  'Admin Tematik',
  'Admin Validasi',
  'Member Sipilot',
  'Kasubsi Tematik',
  'Admin Buku Tanah',
  'Admin Pola Ruang',
  'Kasubsi Pola Ruang',
  'Kasubsi Pendaftaran'
]
roles.each do |role|
  Role.find_or_create_by(name: role)
end

# admin seeding
users = [
  { role: 'Admin Validasi', email: 'admin@validasi.com', password: 'admin123', username: 'admin_validasi', fullname: 'admin_validasi' },
  { role: 'Admin Tematik', email: 'admin@tematik.com', password: 'admin123', username: 'admin_tematik', fullname: 'admin_tematik' },
  { role: 'Admin Buku Tanah', email: 'admin@bukutanah.com', password: 'admin123', username: 'admin_bukutanah', fullname: 'admin_bukutanah' },
  { role: 'Admin Pola Ruang', email: 'admin@polaruang.com', password: 'admin123', username: 'admin_polaruang', fullname: 'admin_polaruang' },
  { role: 'Admin Intip', email: 'admin@intip.com', password: 'admin123', username: 'admin_intip', fullname: 'admin_intip' },
  { role: 'Admin GPS', email: 'admin@gps.com', password: 'admin123', username: 'admin_gps', fullname: 'admin_gps' },
  { role: 'Member Sipilot', email: 'member@sipilot.com', password: 'member123', username: 'member_sipilot', fullname: 'member_sipilot' },
  { role: 'Member Intip', email: 'member@intip.com', password: 'member123', username: 'member_intip', fullname: 'member_intip' },
  { role: 'Member GPS', email: 'member@gps.com', password: 'member123', username: 'member_gps', fullname: 'member_gps' },
  { role: 'Kasubsi Tematik', email: 'kasubsi@tematik.com', password: 'kasubsi123', username: 'kasubsi_tematik', fullname: 'kasubsi_tematik' },
  { role: 'Kasubsi Pola Ruang', email: 'kasubsi@polaruang.com', password: 'kasubsi123', username: 'kasubsi_polaruang', fullname: 'kasubsi_polaruang' },
  { role: 'Kasubsi Pendaftaran', email: 'kasubsi@pendaftaran.com', password: 'kasubsi123', username: 'kasubsi_pendaftaran', fullname: 'kasubsi_pendaftaran' },
  { role: 'Super User', email: 'user@super.com', password: 'superuser', username: 'superuser', fullname: 'superuser' },
  { role: 'Super Admin', email: 'admin@super.com', password: 'superadmin', username: 'superadmin', fullname: 'superadmin' }
]

users.each do |user_hash|
  usr = User.new(email: user_hash[:email], password: user_hash[:password], username: user_hash[:username])
  usr.skip_confirmation!
  if usr.save
    role_id = Role.find_by(name: user_hash[:role]).id
    UserDetail.find_or_create_by(fullname: user_hash[:fullname], user_id: usr.id)
    UserRole.find_or_create_by(role_id: role_id, user_id: usr.id)
    puts usr.as_json
  end
  puts '======> SEEDING USERS'
end

# district seeding
districts = ['KABUPATEN KLATEN', 'KABUPATEN SRAGEN']
districts.each do |district|
  District.find_or_create_by(name: district)

  puts district
  puts '======> SEEDING DISTRICTS'
end

# sub districts seeding
sub_districts = CSV.read("#{Rails.root}/db/data/region_klaten.csv")
sub_districts.each do |value|
  sub_district = value.second
  village = value.third
  sd = SubDistrict.find_or_create_by(name: sub_district)
  sd.update(district_id: District.find_by(name: 'KABUPATEN KLATEN').id)
  Village.find_or_create_by(name: village, sub_district_id: sd.id)

  puts "#{sub_district} - #{village}"
  puts '======> SEEDING SUB DISTRICTS'
end

# hak type seeding
hak_types = [
  'Hak Milik (HM)',
  'Hak Guna Bangunan (HGB)',
  'Hak Pakai (HP)',
  'Hak Guna Usaha (HGU)',
  'Hak Pengelolaan (HP)'
]
hak_types.each do |ht|
  HakType.find_or_create_by(name: ht)
  puts ht
  puts '======> SEEDING HAK TYPES'
end

# Service Seeding
services = [ 'Pola Ruang', 'Validasi' ]
services.each do |srv|
  Service.find_or_create_by(name: srv)
  puts srv
  puts '======> SEEDING HAK TYPES'
end

alas_types = [
  'Girik',
  'Pipil',
  'Patok',
  'Letter C',
  'Ground Kart',
  'SPPT',
  'SKT'
]
alas_types.each do |alas|
  AlasType.find_or_create_by(name: alas)
end


#  Area
areas = [
  { name: 'Klaten', area_id: 1, district_id: District.find_by(name: 'KABUPATEN KLATEN').id, base_url: 'klaten.sipilot.id', is_default: true },
  { name: 'Sragen', area_id: 2, district_id: District.find_by(name: 'KABUPATEN SRAGEN').id, base_url: 'sragen.sipilot.id', is_default: false }
]
areas.each do |area|
  Area.find_or_create_by(name: area[:name], area_id: area[:area_id], district_id: area[:district_id], is_default: area[:is_default])
end
