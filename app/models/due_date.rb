class DueDate < ApplicationRecord
  # validate :due_at_is_valid_datetime
  validates :due_at, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\z/, message: 'must be a valid datetime' }

  #  has_paper_trail

  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end
  def self.current_due_date(due_dates)
    # Get the current due date from list of due dates
    due_dates.detect { |due_date| due_date.due_at > Time.now }
  end



  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(parent_id: old_assignment_id)
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.parent_id = new_assignment_id
      new_due_date.save
    end
  end


  def <=>(other)
    if self.due_at && other.due_at
      self.due_at <=>other.due_at
    elsif self.due_at
      -1
    else
      1
    end
  end

  def self.deadline_sort(due_dates)
    due_dates.sort
  end
  

  def self.assignment_latest_review_round(assignment_id, response)
    # for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    return 0 if ResponseMap.where(id: response.map_id, type: 'ReviewResponseMap').empty?

    # sorted so that the earliest deadline is at the first
    sorted_deadlines = deadline_sort(DueDate.where(parent_id: assignment_id))
    round = 1
    sorted_deadlines.each do |due_date|
      if response.created_at < due_date.due_at
        break
      elsif due_date.deadline_type_id == 2
        round += 1
      end
    end
    round
  end
end

