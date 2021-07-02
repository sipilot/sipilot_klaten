class Note < ApplicationRecord
  belongs_to :submission
  enum note_type: { 'Admin Buku Tanah' => 1, 'Admin Validasi' => 2, 'Admin Pola Ruang' => 3 }
end
