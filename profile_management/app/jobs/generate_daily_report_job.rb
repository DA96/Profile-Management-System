class GenerateDailyReportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    User.where(created_at: Date.today.all_day).count
  end
end
