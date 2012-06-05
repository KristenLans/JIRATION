require 'rubygems'
# we need a gem to interact with JIRA. We're gonna use jiralicious.
require 'jiralicious'
# configuration should be stored outside of this app girl! (private data m'kay! out of version control girl!)
require './config.rb'

module Jiralicious
  class Issue
    attr_accessor :pain
    attr_accessor :matuserpain
    attr_accessor :issue_link
  end
end



# We need to get the issues from JIRA by searching for specific issues
def fetch_issues
  result = Jiralicious.search('project = WEB AND (issuetype = "Agile bug" OR issuetype = Bug) AND status in (Open, "In Progress", Reopened, "Needs More Information")') # Any jql can be used here 
  issues = result.issues
  # THIS JUST IN: we have issues
  
  # We need to calculate userpain value based on the values of three custom JIRA fields: Type, Urgency, and Impact. User pain= Type * Urgency * Impact / Max Possible Score.
  issues.each do|issue| 
    unless issue.seriousness.nil? || issue.impact.nil? || issue.urgency.nil?
      seriousness = issue.seriousness['value'].chars.first.to_i
      impact = issue.impact['value'].chars.first.to_i
      urgency = issue.urgency['value'].chars.first.to_i
      # We need to calculate userpain
      issue.pain =  (seriousness * urgency * impact)/175.to_f      
      #Age in days of the ticket
      age = (Time.now.to_i - Time.parse(issue.created).to_i)/60/60/24
      #userpain with maturity
      issue.matuserpain = issue.pain + (age * 0.02)/100
    else
      issue.matuserpain = 0
    end
    issue.issue_link = "https://jira.eol.org/browse/#{issue.jira_key}"
  end
  return issues
end