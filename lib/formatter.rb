class Formatter
  def self.date_dmy(date)
    date.strftime('%d-%m-%Y')
  rescue StandardError
    ''
  end
end
