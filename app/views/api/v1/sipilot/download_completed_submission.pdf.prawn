require "open-uri"

prawn_document do |pdf|
  @submissions_exports.each do |row|

    # TITLE 1
    pdf.float {
      pdf.image "#{Rails.root}/app/assets/images/logo-klaten.png", width: 50, height: 50
    }
    pdf.font_size(15) {
      pdf.text "KEMENTERIAN AGRARIA DAN TATA RUANG /", align: :center, style: :bold
      pdf.text "BADAN PERTANAHAN NASIONAL", align: :center, style: :bold
    }
    pdf.text "KANTOR PERTANAHAN KABUPATEN SRAGEN", align: :center, size: 12
    pdf.text "Jl. Veteran No. 10 Tlp. 0271-891075 http://kab-sragen.atrbpn.go.id", align: :center, size: 10
    pdf.move_down(10)

    # DRAW LINE
    pdf.stroke_horizontal_rule
    pdf.move_down(10)

    if row.service_name == "Pola Ruang"

      # TITLE 2
      title ||= "BUKTI INFORMASI TERVALIDASI" if row.service_name == "Validasi"
      title ||= "INFORMASI POLA RUANG" if row.service_name == "Pola Ruang"
      title ||= "BUKTI INFORMASI SIPILOT"
      pdf.font_size(15) { pdf.text title, style: :bold, align: :center }
      pdf.move_down(5)

      # BERKAS NUMBER
      pdf.font_size(8) { pdf.text "No. Berkas Online: #{row.submission_code}", align: :right }
      pdf.move_down(10)

      # CONTENT ==================
      pdf.font_size(8) { pdf.text "Bidang tanah terletak di :" }
      data = [
        ["Alamat", ": #{row.land_address}"],
        ["Desa", ": #{row.village_name}"],
        ["Kecamatan", ": #{row.sub_district_name}"],
        ["Kabupaten", ": KABUPATEN SRAGEN"],
        ["Provinsi", ": JAWA TENGAH"],
      ]

      pdf.table data, cell_style: {
                        width: 150,
                        height: 17,
                        border_width: 0,
                        min_font_size: 8,
                        overflow: :shrink_to_fit,
                      }
      pdf.move_down(15)

      pdf.font_size(8) { pdf.text "Berdasarkan dokumen yang dilampirkan untuk permohonan Informasi Pola Ruang dengan bukti :" }
      data = [
        ["Alas Hak", ": #{row.alas_name}"],
        ["Nomor", ": #{row.hak_number}"],
        ["Jenis Hak", ": #{row.hak_name}"],
        ["NIB", ": #{row.nib}"],
        # ["Atas Nama", ": #{row.hak_type_id === 1 ? "Diri sendiri" : "Kuasa"}"],
        ["Atas Nama", ": #{row.on_behalf}"],
      ]
      pdf.table data, cell_style: {
                        width: 150,
                        height: 17,
                        border_width: 0,
                        min_font_size: 8,
                        overflow: :shrink_to_fit,
                      }
      pdf.move_down(15)

      # MAPS
      coordinates = [
        ["Lat", ": #{row.lattitude}"],
        ["Long", ": #{row.longitude}"],
      ]
      pdf.font_size(8) { pdf.text "SISTEM KOORDINAT GEOGRAPHIC (LAT/LONG)", style: :bold }
      pdf.table coordinates, cell_style: {
                               width: 150,
                               height: 17,
                               border_width: 0,
                               min_font_size: 8,
                               overflow: :shrink_to_fit,
                             }
      pdf.move_down(5)
      begin
        pdf.image open("https://maps.googleapis.com/maps/api/staticmap?center=#{row.lattitude},#{row.longitude}&zoom=17&size=200x200&&markers=color:red%7Clabel:C%7C#{row.lattitude},#{row.longitude}&maptype=roadmap&key=#{ENV["MAPS_API_KEY"]}")
      rescue StandardError
        pdf.text ""
      end
      pdf.move_down(5)
      pdf.font_size(8) { pdf.text "Basemap Roadmap Google Satellite #{Time.now.strftime("%Y")}" }
      pdf.move_down(15)

      pdf.font_size(9) {
        pdf.text "Berdasarkan Peraturan Daerah Kabupaten Sragen Nomor 1 Tahun 2020 tanggal 5 Mei 2020 tentang Perubahan Atas Peraturan Daerah Kabupaten Sragen Nomor 11 Tahun 2011 tentang Rencana Tata Ruang Wilayah Kabupaten Sragen Tahun 2011-2031"
      }
      pdf.move_down(15)

      pdf.font_size(9) {
        pdf.text "Bahwa lokasi dimaksud sesuai arahan pola ruang peraturan di atas, ditetapkan sebagai:"
      }
      pdf.font_size(9) {
        pdf.text row.admin_referral, style: :bold
      }
      pdf.move_down(15)

      # END CONTENT ==================

      # FOOTER ==================
      pdf.font_size(9) {
        pdf.text "Sragen, #{I18n.l DateTime.now, locale: :id, format: :short}", align: :right
      }
      pdf.move_down(5)
      pdf.image "#{Rails.root}/app/assets/images/logo-sipilot-file.jpg", width: 50, height: 50, position: :right
    else
      # title ||= "BUKTI INFORMASI TERVALIDASI MELALUI SIPILOT" if row.service_name == "Validasi"
      # title ||= "BUKTI INFORMASI POLA RUANG MELALUI SIPILOT" if row.service_name == "Pola Ruang"
      # title ||= "BUKTI INFORMASI SIPILOT"

      # pdf.image "#{Rails.root}/app/assets/images/logo-sipilot-file.jpg", width: 50, height: 50
      # pdf.move_down(10)
      # pdf.font_size(15) { pdf.text title, style: :bold }
      # pdf.move_down(10)

      # TITLE 2
      title ||= "PLOTTING BIDANG TANAH" if row.service_name == "Validasi"
      title ||= "BUKTI INFORMASI POLA RUANG MELALUI SIPILOT" if row.service_name == "Pola Ruang"
      title ||= "BUKTI INFORMASI SIPILOT"
      pdf.font_size(15) { pdf.text title, style: :bold, align: :center }
      pdf.move_down(5)

      # BERKAS NUMBER
      pdf.font_size(8) { pdf.text "No. Berkas Online: #{row.submission_code}", align: :right }
      pdf.move_down(10)

      # CONTENT ==================
      pdf.font_size(8) { pdf.text "Bidang tanah terletak di :" }
      data = [
        ["Alamat", ": #{row.land_address}"],
        ["Desa", ": #{row.village_name}"],
        ["Kecamatan", ": #{row.sub_district_name}"],
        ["Kabupaten", ": KABUPATEN SRAGEN"],
        ["Provinsi", ": JAWA TENGAH"],
      ]

      pdf.table data, cell_style: {
                        width: 150,
                        height: 17,
                        border_width: 0,
                        min_font_size: 8,
                        overflow: :shrink_to_fit,
                      }

      pdf.move_down(15)

      pdf.font_size(8) { pdf.text "Berdasarkan dokumen yang dilampirkan untuk permohonan Validasi Data Pertanahan dengan bukti :" }
      data = [
        ["Alas Hak", ": #{row.alas_name}"],
        ["Nomor", ": #{row.hak_number}"],
        ["Jenis Hak", ": #{row.hak_name}"],
        ["NIB", ": #{row.nib}"],
        # ["Atas Nama", ": #{row.on_behalf}"],
        ["Atas Nama", ": #{row.hak_type_id === 1 ? "Diri sendiri" : "Kuasa"}"],
      ]
      pdf.table data, cell_style: {
                        width: 150,
                        height: 17,
                        border_width: 0,
                        min_font_size: 8,
                        overflow: :shrink_to_fit,
                      }
      pdf.move_down(15)

      pdf.font_size(8) {
        pdf.text "SISTEM KOORDINAT GEOGRAPHIC (LAT/LONG)", style: :bold
      }

      coordinates = [
        [{ :content => "Lat", size: 8 }, { :content => ": #{row.lattitude}", size: 8 }],
        [{ :content => "Long", size: 8 }, { :content => ": #{row.longitude}", size: 8 }],
      ]

      pdf.table coordinates, cell_style: {
                               width: 150,
                               height: 17,
                               border_width: 0,
                               min_font_size: 8,
                               overflow: :shrink_to_fit,
                             }
      pdf.move_down(5)
      begin
        pdf.image open("https://maps.googleapis.com/maps/api/staticmap?center=#{row.lattitude},#{row.longitude}&zoom=17&size=200x200&&markers=color:red%7Clabel:C%7C#{row.lattitude},#{row.longitude}&maptype=roadmap&key=#{ENV["MAPS_API_KEY"]}")
      rescue StandardError
        pdf.text ""
      end

      pdf.move_down(5)
      pdf.font_size(8) {
        pdf.text "Basemap: Roadmap Google Satellite #{Time.now.strftime("%Y")}"
      }
      pdf.move_down(10)

      pdf.font_size(8) {
        pdf.text "Catatan :", style: :bold
      }
      pdf.move_down(5)
      # pdf.text "- Tunjukkan bukti ini kepada admin sipilot di Kantor Pertanahan"
      notes = [
        [{ :content => "1. ", size: 8 }, { :content => "Plotting bidang tanah ini bukan merupakan Tanda Bukti Hak Atas Tanah.", size: 8 }],
        [{ :content => "2. ", size: 8 }, { :content => "Posisi/letak titik koordinat bidang tanah berdasarkan dari informasi pengguna layanan", size: 8 }],
        [{ :content => "3. ", size: 8 }, { :content => "Pengguna layanan bertanggung jawab penuh baik secara pidana maupun perdata tanpa melibatkan pihak lain terhadap segala bentuk permasalahan atau resiko hukum yang mungkin terjadi di kemudian hari apabila terjadi kesalahan penunjukan yang dilakukan oleh pengguna layanan", size: 8 }],
      ]
      pdf.table notes, cell_style: {
                         :padding => [0, 0, 0, 0],
                         #  height: 15,
                         border_width: 0,
                         #  min_font_size: 8,
                         overflow: :shrink_to_fit,
                       }
      pdf.move_down(10)
      # FOOTER ==================

      imagefile = "#{Rails.root}/app/assets/images/logo-sipilot-file.jpg"
      pdf.table([
        [
          {
            :content => "No", width: 15, align: :center, size: 8,
          },
          {
            :content => "Petugas",
            size: 8,
          },
          {
            :content => "Nama",
            size: 8,
          },
          {
            :content => "Keterangan", size: 8,
          }, {
            :content => "", border_width: 0,
          }, {
            :content => "Sragen, #{I18n.l DateTime.now, locale: :id, format: :short}",
            border_width: 0,
            align: :right,
            size: 9,
          },
        ],
        [{ :content => "1", width: 15, align: :center, size: 8 },
         { :content => "Petugas <em>Ploting</em>", size: 8 }, "", "", { :content => "", border_width: 0 }, {
          :image => imagefile,
          :image_height => 50,
          :image_width => 50,
          :rowspan => 3,
          border_width: 0,
          position: :right,
        }],
        [{ :content => "2", width: 15, align: :center, size: 8 }, { :content => "Validator", size: 8 }, "", "", { :content => "", border_width: 0 }],
        [{ :content => "", border_width: 0, :colspan => 4 }],
      ], cell_style: {
           inline_format: true,
         #  height: 10,
         #  font_size: 8,
         }, width: pdf.bounds.width)
    end

    unless @submissions_exports[-1].id == row.id
      pdf.start_new_page
    end
  end
end
