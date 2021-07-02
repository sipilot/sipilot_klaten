prawn_document do |pdf|
    pdf.text 'REKAPITULASI BERKAS POLA RUANG'
    pdf.move_down(20)
    submissions_table = @submissions_exports.each.with_index(1).map do |submission, index|
        [
        index,
        submission.submission_code,
        submission.nib,
        submission.hak_number,
        submission.on_behalf,
        submission.act_for,
        submission.fullname,
        submission.hak_name,
        submission.village_name,
        submission.space_pattern_status,
        submission.kasubsi_space_pattern_status
        ]
    end
    headers = [
        'No', 'Kode', 'NIB','Nomor Hak', 'Nama Pendaftar', 'Bertindak Atas',
        'Nama Pemilik Sertipikat', 'Jenik Hak', 'Desa', 'Status Pola Ruang', 
        'Status Kasubsi Pola Ruang'
    ]
    submissions_table.unshift headers
    pdf.table submissions_table, header: true, row_colors: ['FFFFFF','DDDDDD'], cell_style: { size: 5 }
    pdf.move_down(20)
    pdf.text "Exported at : #{Time.now.strftime('%d-%m-%Y')}"
end
