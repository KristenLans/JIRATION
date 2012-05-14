# because we;e usign Ruy 1.8 we need to require rubygems if we're going to use gems.
require 'rubygems'
# we want a radical stylization
require 'haml'
# we need a gem to interact with JIRA. We're gonna use jiralicious.
require 'jiralicious'
# configuration should be stored outside of this app girl! (private data m'kay! out of version control girl!)
require './config.rb'
# we need a web server. We're using the sinatra gem girl!
require 'sinatra'

module Jiralicious
  class Issue
    attr_accessor :pain
    attr_accessor :matuserpain
  end
end



# when a user goes to the root of the app, jiralicious.eol.org, they will see a list of JIRA issues.
get '/' do
  # We need to get the issues from JIRA by searching for specific issues
  
  result = Jiralicious.search('project = WEB AND issuetype = Bug AND fixVersion = 10408 AND status in (Open, "In Progress", Reopened, "Needs More Information") ORDER BY priority DESC') # Any jql can be used here 
  @issues = result.issues
  # THIS JUST IN: we have issues
  
  # We need to calculate userpain value based on the values of three custom JIRA fields: Type, Urgency, and Impact. User pain= Type * Urgency * Impact / Max Possible Score.
  @issues.each do|issue| 
    unless issue.seriousness.nil? || issue.impact.nil? || issue.urgency.nil?
      seriousness = issue.seriousness['value'].chars.first.to_i
      impact = issue.impact['value'].chars.first.to_i
      urgency = issue.urgency['value'].chars.first.to_i
      # We need to calculate userpain
      issue.pain =  (seriousness * urgency * impact)/175.to_f      
      #Age in days of the ticket
      age = (Time.now.to_i - Time.parse(issue.created).to_i)/60/60/24
      #userpain with maturity
      issue.matuserpain = issue.pain + (age * 0.02)
    else
      issue.matuserpain = 0
    end
  end

@issues = @issues.sort_by { |a| [ a.matuserpain ] }
  
  # We need to sort issues by userpain
  
  # render results to browser
  
  # 
  haml :index, :locals => {:issues => @issues}
end

