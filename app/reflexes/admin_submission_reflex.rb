class AdminSubmissionReflex < ApplicationReflex
  def set_nib
    @value = element.attributes[:value]
    @submission_id = element.dataset[:submission_id]
    submission = Submission.find_by(id: @submission_id)
    submission.nib = @value
    submission.save
  end
end
