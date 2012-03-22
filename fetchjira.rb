require 'rubygems'
require 'jiralicious'
require './config.rb'

result = Jiralicious.search('project = WEB AND issuetype = Bug AND fixVersion = 10408 AND status in (Open, "In Progress", Reopened, "Needs More Information") ORDER BY priority DESC') # Any jql can be used here
result.issues.each do |plizoo|
  puts plizoo.jira_key
  puts plizoo.priority.name
  puts plizoo.summary
end
