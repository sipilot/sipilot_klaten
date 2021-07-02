prawn_document do |pdf|
  pdf.text 'Permohonan Hari Ini'

  if @gteq_params.present? && @lteq_params.present?
    pdf.move_down(10)
    pdf.text "Dari : #{@gteq_params}, Sampai : #{@lteq_params}"
  end

  pdf.move_down(10)
  pdf.text "Di Export pada : #{Time.now.strftime('%d-%m-%Y')}"
  pdf.move_down(20)

  left = 0
  bottom = 650

  @exports.each do |submission|
    pdf.text "Nomor Pendaftaran : #{submission.submission_code}"

    images ||= submission.measuring_letter_images if @role == 'admin validasi'
    images ||= submission.land_book_images

    images.each.with_index(1) do |file, index|
      if [3, 7].include? index
        left = 0
        bottom = 350
      end

      if index == 5
        pdf.start_new_page
        left = 0
        bottom = 650
      end

      begin
        pdf.image StringIO.open(file.image.download), at: [left, bottom], width: 210
      rescue StandardError
        pdf.text 'Gambar Tidak Ditemukan'
      end
      left += 230
    end

    left = 0
    bottom = 650

    unless @exports.last.id == submission.id
      pdf.start_new_page
    end
  end
end
