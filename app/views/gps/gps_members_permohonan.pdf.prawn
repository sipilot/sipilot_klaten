prawn_document do |pdf|
  pdf.text 'Semua Permohonan'

    if @gteq_params.present? && @lteq_params.present?
      pdf.move_down(10)
      pdf.text "Dari : #{@gteq_params}, Sampai : #{@lteq_params}"
    end

    pdf.move_down(10)
    pdf.text "Di Export pada : #{Time.now.strftime('%d-%m-%Y')}"
    pdf.move_down(20)

    left = 0
    bottom = 650

  @gps_plottings.each do |submission|
    submission.submission_files.each.with_index(1) do |file, index|
      if index == 3 || index == 7
        left = 0
        bottom = 350
      end

      if index == 5
        pdf.start_new_page
        left = 0
        bottom = 650
      end

      begin
        pdf.image StringIO.open(file.image.download), at: [left, bottom], width: 100
      rescue StandardError
        pdf.text 'Gambar Tidak Ditemukan'
      end

      left += 150
    end

    left = 0
    bottom = 650

    unless @gps_plottings.last.id == submission.id
      pdf.start_new_page
    end
  end
end
