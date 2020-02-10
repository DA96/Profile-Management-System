class GenerateReportWorker
  include Sidekiq::Worker

  def perform(*args)
    #Purpose: count all users created today and store the count in file
    @todayusers_count = User.where(created_at: Date.today.all_day).count

  	file = File.open("Report.txt", "w")
  	file.puts "Users created today: #{@todayusers_count} on Date: #{Date.today}"
  	file.close
  end

  #Sidekiq::Cron::Job.create(name: 'GenerateReportWorker-every day', cron: '/1 * * * *', class: 'GenerateReportWorker' )
end
