require 'json'
require 'csv'
require './lib/jira.rb'

CSV.open("sprint.csv", "wb") do |csv|
  csv << ["issue,summary,status,units"]
  fetch_sprint.each do |issue|
    units = issue["fields"]["customfield_10030"].to_i || 0
    csv << [issue["key"],issue["fields"]["summary"],issue["fields"]["status"]["name"],units]
  end
end
