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
    title ||= "BUKTI INFORMASI TERVALIDASI MELALUI SIPILOT" if submission.service_name == "Validasi"
    title ||= "INFORMASI POLA RUANG" if submission.service_name == "Pola Ruang"
    title ||= "BUKTI INFORMASI SIPILOT"
    pdf.font_size(15) { pdf.text title, style: :bold, align: :center }
    pdf.move_down(5)
    #endtitle

    # BERKAS NUMBER
    pdf.font_size(8) { pdf.text "No. Berkas Online: <strong>#{submission.submission_code}</strong>", align: :right, inline_format: true }
    pdf.move_down(10)

    pdf.text "Service name : #{submission.service_name}"
    #end new header

    # pdf.image "#{Rails.root}/app/assets/images/logo-sipilot-file.jpg", width: 50, height: 50
    # pdf.move_down(10)
    # pdf.move_down(10)
    # pdf.stroke_horizontal_rule
    # pdf.move_down(15)

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
    #end content 1

    if submission.service_name == "Pola Ruang"
      # content 2 pola ruang
      pdf.font_size(8) { pdf.text "Berdasarkan dokumen yang dilampirkan untuk permohonan Informasi Pola Ruang dengan bukti:" }
      # pdf.text submission.to_json
      data2 = [
        ["Alas Hak", ": #{submission.alas_name}"],
        ["Nomor", ": #{submission.hak_number}"],
        ["Jenis Hak", ": #{submission.hak_name}"],
        ["NIB", ": #{submission.nib}"],
        # ["Atas Nama", ": #{submission.act_for === "Diri sendiri" ? "Diri sendiri" : submission.on_behalf}"],
        ["Atas Nama", ": #{submission.on_behalf}"],
      ]
      pdf.table data2, cell_style: {
                        width: 150,
                        height: 17,
                        border_width: 0,
                        min_font_size: 8,
                        overflow: :shrink_to_fit,
                      }
      pdf.move_down(15)
      #end content 2
    end

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

    coordinates = [
      ["Lat", ": #{submission.lattitude}"],
      ["Long", ": #{submission.longitude}"],
    ]
    pdf.text "SISTEM KOORDINAT GEOGRAPHIC (LAT/LONG)", style: :bold
    pdf.table coordinates, cell_style: {
                             width: 150,
                             height: 30,
                             border_width: 0,
                             min_font_size: 8,
                             overflow: :shrink_to_fit,
                           }
    pdf.move_down(15)

    if submission.service_name == "Pola Ruang"
      pdf.text "ARAHAN POLA RUANG: #{submission.admin_referral}", style: :bold
      pdf.move_down(5)
      pdf.text "Berdasarkan Peraturan Daerah Kabupaten Klaten Nomor 11 Tahun 2011 tentang Rencana Tata Ruang Wilayah (RTRW) Tahun 2011 - 2031"
      pdf.move_down(15)
    end

    unless submission.service_name == "Pola Ruang"
      pdf.text "SELAMAT BERKAS ANDA TELAH TER-VALIDASI", style: :bold
      pdf.move_down(15)
    end

    begin
      pdf.image open("https://maps.googleapis.com/maps/api/staticmap?center=#{submission.lattitude},#{submission.longitude}&zoom=17&size=300x300&&markers=color:red%7Clabel:C%7C#{submission.lattitude},#{submission.longitude}&maptype=hybrid&key=#{ENV["MAPS_API_KEY"]}")
    rescue StandardError
      pdf.text ""
    end

    pdf.move_down(5)
    pdf.text "Basemap: Citra Google Satellite #{Time.now.strftime("%Y")}"
    pdf.move_down(15)

    pdf.text "Catatan :", style: :bold
    pdf.move_down(5)
    pdf.text "- Tunjukkan bukti ini kepada admin sipilot di Kantor Pertanahan"

    unless @submissions_exports[-1].id == submission.id
      pdf.start_new_page
    end
  end
end
