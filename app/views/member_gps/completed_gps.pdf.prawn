prawn_document do |pdf|
    pdf.text 'Berkas Selesai'
    pdf.move_down(20)
    submissions_table = @submissions_exports.each.with_index(1).map do |submission, index|
      [
        index,
        submission.hak_number,
        submission.on_behalf,
        submission.act_for,
        submission.fullname,
        submission.hak_name,
        submission.village_name
      ]
    end
    headers = [
      'No', 'Nomor Hak', 'Nama Pendaftar', 'Bertindak Atas',
      'Nama Pemilik Sertipikat', 'Jenik Hak', 'Desa'
    ]
    submissions_table.unshift headers
    pdf.table submissions_table, header: true, row_colors: ['FFFFFF','DDDDDD'], cell_style: { size: 5 }
    pdf.move_down(20)
    pdf.text "Exported at : #{Time.now.strftime('%d-%m-%Y')}"
  end
  