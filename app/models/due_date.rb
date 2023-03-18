# Class to manage Due Dates of Assignments & Signup Sheet Topics
class DueDate < ApplicationRecord
  validates :due_at, presence: true, if: -> { :due_at.to_s.is_a?(DateTime) }
  #  has_paper_trail

  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
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
    if due_at && other.due_at
      due_at <=> other.due_at
    elsif due_at
      -1
    else
      1
    end
  end
  
  def self.deadline_sort(due_dates)
    due_dates.sort
  end
end
