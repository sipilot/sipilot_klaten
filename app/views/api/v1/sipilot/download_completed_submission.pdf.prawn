require "open-uri"

prawn_document do |pdf|
  @submissions_exports.each do |submission|

    ##new header
    pdf.float {
      pdf.image "#{Rails.root}/app/assets/images/logo-klaten.png", width: 50, height: 50
    }
    pdf.font_size(15) {
      pdf.text "KEMENTERIAN AGRARIA DAN TATA RUANG /", align: :center, style: :bold
      pdf.text "BADAN PERTANAHAN NASIONAL", align: :center, style: :bold
    }
    pdf.text "KANTOR PERTANAHAN KABUPATEN SRAGEN", align: :center, size: 12
    pdf.text "Jalan Veteran Nomor 88, Kelurahan Barenglor, Kecamatan Klaten Utara, Klaten, Kode", align: :center, size: 10
    pdf.text "pos: 57438, Telepon: (0272) 321983, Website: kab-klaten.atrbpn.go.id.", align: :center, size: 10
    pdf.move_down(10)

    # DRAW LINE
    pdf.stroke_horizontal_rule
    pdf.move_down(10)

    #title
    title ||= "<em><strong>PLOTTING</strong></em> BIDANG TANAH" if submission.service_name == "Validasi"
    title ||= "INFORMASI POLA RUANG" if submission.service_name == "Pola Ruang"
    title ||= "BUKTI INFORMASI SIPILOT"
    pdf.font_size(15) { pdf.text title, style: :bold, align: :center, inline_format: true }
    pdf.move_down(5)
    #endtitle

    # BERKAS NUMBER
    pdf.font_size(8) { pdf.text "No. Berkas Online: <strong>#{submission.submission_code}</strong>", align: :right, inline_format: true }
    pdf.move_down(10)

    #end new header

    #Constent 1
    pdf.font_size(8) { pdf.text "Bidang tanah terletak di :" }
    data = [
      ["Alamat", ": #{submission.land_address}"],
      ["Desa", ": #{submission.village_name}"],
      ["Kecamatan", ": #{submission.sub_district_name}"],
      ["Kabupaten", ": Klaten"],
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
    #Constent 1
    if submission.service_name == "Pola Ruang"
      #content 2
      pdf.font_size(8) {
        pdf.text "Berdasarkan dokumen yang dilampirkan untuk permohonan Informasi Pola Ruang dengan bukti:"
      }

      data = [
        ["Alas Hak", ": alas name"],
        ["Nomor", ": #{submission.hak_number}"],
        ["Jenis Hak", ": #{submission.hak_name}"],
        ["NIB", ": #{submission.nib}"],
        # ["Atas Nama", ": #{submission.hak_type_id === 1 ? "Diri sendiri" : "Kuasa"}"],
        ["Atas Nama", ": #{submission.on_behalf}"],
      ]
      pdf.table data, cell_style: {
                        width: 150,
                        height: 17,
                        border_width: 0,
                        min_font_size: 8,
                        overflow: :shrink_to_fit,
                      }
      pdf.move_down(15)
      #end content 2
      # MAPS
      pdf.font_size(8) { pdf.text "SISTEM KOORDINAT GEOGRAPHIC (LAT/LONG)", style: :bold }
      coordinates = [
        ["Lat", ": #{submission.lattitude}"],
        ["Long", ": #{submission.longitude}"],
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
        pdf.image open("https://maps.googleapis.com/maps/api/staticmap?center=#{submission.lattitude},#{submission.longitude}&zoom=17&size=200x200&&markers=color:red%7Clabel:C%7C#{submission.lattitude},#{submission.longitude}&maptype=roadmap&key=#{ENV["MAPS_API_KEY"]}")
      rescue StandardError
        pdf.text ""
      end
      pdf.move_down(5)
      pdf.font_size(8) {
        pdf.text "Basemap <em>Roadmap Google Satellite</em> #{Time.now.strftime("%Y")}", inline_format: true
      }
      #end maps
      #catatan
      pdf.move_down(10)
      pdf.font_size(8) {
        pdf.text("Berdasarkan <strong>Peraturan Daerah Kabupaten Klaten Nomor 11 Tahun 2011</strong> tentang Rencana Tata Ruang Wilayah Kabupaten Klaten Tahun 2011-2031, bahwa lokasi yang dimaksud sesuai arahan pola ruang peraturan tersebut di atas, ditetapkan sebagai:", inline_format: true)
      }
      pdf.text("<strong>#{submission.admin_referral}</strong>", font_size: 8, inline_format: true)
      #end catatan

      #start ttd
      pdf.font_size(9) {
        pdf.text "Klaten, #{I18n.l DateTime.now, locale: :id, format: :short}", align: :right
      }
      pdf.move_down(5)
      pdf.image "#{Rails.root}/app/assets/images/logo-sipilot-file.jpg", width: 50, height: 50, position: :right
      #end ttd
    end

    if submission.service_name == "Validasi"
      #content 2
      pdf.font_size(8) {
        pdf.text "Berdasarkan dokumen yang dilampirkan untuk permohonan Validasi Data Pertanahan dengan bukti:"
      }
      data = [
        ["Alas Hak", ": alas name"],
        ["Nomor", ": #{submission.hak_number}"],
        ["Jenis Hak", ": #{submission.hak_name}"],
        ["NIB", ": #{submission.nib}"],
        # ["Atas Nama", ": #{submission.hak_type_id === 1 ? "Diri sendiri" : "Kuasa"}"],
        ["Atas Nama", ": #{submission.on_behalf}"],
      ]
      pdf.table data, cell_style: {
                        width: 150,
                        height: 17,
                        border_width: 0,
                        min_font_size: 8,
                        overflow: :shrink_to_fit,
                      }
      pdf.move_down(15)
      #endcontent 2
      # MAPS
      pdf.font_size(8) { pdf.text "SISTEM KOORDINAT GEOGRAPHIC (LAT/LONG)", style: :bold }
      coordinates = [
        ["Lat", ": #{submission.lattitude}"],
        ["Long", ": #{submission.longitude}"],
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
        pdf.image open("https://maps.googleapis.com/maps/api/staticmap?center=#{submission.lattitude},#{submission.longitude}&zoom=17&size=200x200&&markers=color:red%7Clabel:C%7C#{submission.lattitude},#{submission.longitude}&maptype=roadmap&key=#{ENV["MAPS_API_KEY"]}")
      rescue StandardError
        pdf.text ""
      end
      pdf.move_down(5)
      pdf.font_size(8) {
        pdf.text "Basemap <em>Roadmap Google Satellite</em> #{Time.now.strftime("%Y")}", inline_format: true
      }
      pdf.move_down(5)
      #end maps

      #catatan
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
      #end catatan
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
            :content => "Klaten, #{I18n.l DateTime.now, locale: :id, format: :short}",
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

    ## old
    # data = [
    #   ["No Berkas", ": #{submission.submission_code}"],
    #   ["Tanggal", ": #{submission.date_completion}"],
    #   ["Nomor Hak", ": #{submission.hak_number}"],
    #   ["Jenis Hak", ": #{submission.hak_name}"],
    # ]
    # pdf.table data, cell_style: {
    #                   width: 150,
    #                   height: 30,
    #                   border_width: 0,
    #                   min_font_size: 8,
    #                   overflow: :shrink_to_fit,
    #                 }
    # pdf.move_down(15)

    # coordinates = [
    #   ["Lat", ": #{submission.lattitude}"],
    #   ["Long", ": #{submission.longitude}"],
    # ]
    # pdf.text "SISTEM KOORDINAT GEOGRAPHIC (LAT/LONG)", style: :bold
    # pdf.table coordinates, cell_style: {
    #                          width: 150,
    #                          height: 30,
    #                          border_width: 0,
    #                          min_font_size: 8,
    #                          overflow: :shrink_to_fit,
    #                        }
    # pdf.move_down(15)

    # if submission.service_name == "Pola Ruang"
    #   pdf.text "ARAHAN POLA RUANG: #{submission.admin_referral}", style: :bold
    #   pdf.move_down(5)
    #   pdf.text "Berdasarkan Peraturan Daerah Kabupaten Klaten Nomor 11 Tahun 2011 tentang Rencana Tata Ruang Wilayah (RTRW) Tahun 2011 - 2031"
    #   pdf.move_down(15)
    # end

    # unless submission.service_name == "Pola Ruang"
    #   pdf.text "SELAMAT BERKAS ANDA TELAH TER-VALIDASI", style: :bold
    #   pdf.move_down(15)
    # end

    # begin
    #   pdf.image open("https://maps.googleapis.com/maps/api/staticmap?center=#{submission.lattitude},#{submission.longitude}&zoom=17&size=300x300&&markers=color:red%7Clabel:C%7C#{submission.lattitude},#{submission.longitude}&maptype=hybrid&key=#{ENV["MAPS_API_KEY"]}")
    # rescue StandardError
    #   pdf.text ""
    # end

    # pdf.move_down(5)
    # pdf.text "Basemap: Citra Google Satellite #{Time.now.strftime("%Y")}"
    # pdf.move_down(15)

    # pdf.text "Catatan :", style: :bold
    # pdf.move_down(5)
    # pdf.text "- Tunjukkan bukti ini kepada admin sipilot di Kantor Pertanahan"

    unless @submissions_exports[-1].id == submission.id
      pdf.start_new_page
    end
  end
end
