require 'rubygems'
# we need a gem to interact with JIRA. We're gonna use jiralicious.
require 'jiralicious'
# configuration should be stored outside of this app girl! (private data m'kay! out of version control girl!)
require './config.rb'
require 'gruff'
require 'rmagick'

module Jiralicious
  class Issue
    attr_accessor :pain
    attr_accessor :matuserpain
    attr_accessor :issue_link
    attr_accessor :label
    attr_accessor :age
    
  end
end



# We need to get the issues from JIRA by searching for specific issues
def fetch_issues
  result = Jiralicious.search('project = WEB AND (issuetype = "Agile bug" OR issuetype = Bug) AND status in (Open, "In Progress", Reopened, "Needs More Information")', :max_results => 100) # Any jql can be used here 
  issues = result.issues
  # THIS JUST IN: we have issues
  # create array for totals calculation
  pains = Array.new
  # We need to calculate userpain value based on the values of three custom JIRA fields: Type, Urgency, and Impact. User pain= Type * Urgency * Impact / Max Possible Score.
  issues.each do|issue|
    unless issue.seriousness.nil? || issue.impact.nil? || issue.urgency.nil?
      seriousness = issue.seriousness['value'].chars.first.to_i
      impact = issue.impact['value'].chars.first.to_i
      urgency = issue.urgency['value'].chars.first.to_i
      # We need to calculate userpain
      issue.pain =  (seriousness * urgency * impact)/175.to_f      
      #Age in days of the ticket
      age = (Time.now - Time.parse(issue.created))/60/60/24
      issue.age = age
      #userpain with maturity
      issue.matuserpain = issue.pain + (age * 0.02)/100
    else
      issue.matuserpain = 0
    end
    # We need to get the sum of all current userpain scores and show it at the top of the page.
    pains << issue.matuserpain
    
    if issue.matuserpain > 0.49
      issue.label = "ouch"
    else
      issue.label = "ugh"
    end
    
    issue.issue_link = "https://jira.eol.org/browse/#{issue.jira_key}"
  end
  @total_pain = pains.inject(:+)
  return issues
end


