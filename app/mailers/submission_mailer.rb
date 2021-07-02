class SubmissionMailer < ApplicationMailer
  # based on https://guides.rubyonrails.org/action_mailer_basics.html

  default from: 'support@sipilot.id'

  def submission_done
    @submission_id = params[:id]
    mail(to: params[:email], subject: 'Permohonan Selesai')
  end

  def submission_revisions
    @title    = params[:title]
    @message  = params[:message]
    mail(to: params[:email], subject: 'Revisi')
  end
end
