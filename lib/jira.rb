require 'rubygems'
# we need a gem to interact with JIRA. We're gonna use jiralicious.

require 'open-uri'

require 'json'
require 'awesome_print'

# require 'jiralicious'
# configuration should be stored outside of this app girl! (private data m'kay! out of version control girl!)
require './config.rb'


class Issue
  attr_accessor :key
  attr_accessor :pain
  attr_accessor :matuserpain
  attr_accessor :issue_link
  attr_accessor :label
  attr_accessor :age
  attr_accessor :seriousness
  attr_accessor :impact
  attr_accessor :urgency
  attr_accessor :summary
end

def fetch_issues(project='all')
  @available_projects = %w(WEB DATA)
  unless @available_projects.include? project
    project = @available_projects.join(",")
  end
  query = "project in (#{project}) AND issuetype in (Bug, 'Agile bug') AND status in (Open, 'In Progress', Reopened, 'Needs More Information')&maxResults=100&fields&expand"
  uri = URI::encode("#{API_URI}/rest/api/2/search?jql=#{query}")
  query = open(uri, :http_basic_authentication => [API_USERNAME, API_PASS]).read
  result = JSON.parse(query)
  issues = result['issues']
  # THIS JUST IN: we have issues
  #now we need to get seriousness, impact, and urgency from JIRA custom_fields id
  @seriousness = 'customfield_10331'
  @impact = 'customfield_10333'
  @urgency = 'customfield_10332'
  pains = Array.new
  # we're just gonna grab the stuff we need and make an Issue.
  @tickets = []
  @pains = []
  issues.each do|issue|
    # unless issue['fields'][@seriousness].nil? || issue['fields'][@impact].nil? || issue['fields'][@urgency].nil?
      seriousness = issue['fields'][@seriousness]['value'].chars.first.to_i rescue 0
      impact = issue['fields'][@impact]['value'].chars.first.to_i rescue 0
      urgency = issue['fields'][@urgency]['value'].chars.first.to_i rescue 0
      # We need to calculate userpain
      pain =  (seriousness * urgency * impact)/175.to_f
      #Age in days of the ticket
      ticket = Issue.new
      ticket.key = issue['key']
      ticket.age = (Time.now - Time.parse(issue['fields']['created']))/60/60/24
      ticket.seriousness = seriousness
      ticket.impact = impact
      ticket.urgency = urgency
      ticket.pain = pain
      ticket.summary = issue['fields']['summary']
      ticket.issue_link = "https://jira.eol.org/browse/#{ticket.key}"
      #userpain with maturity
      if ticket.pain == 0
        ticket.matuserpain = 0
      else
        ticket.matuserpain = ticket.pain + (ticket.age * 0.02)/100
      end
      # ticket.matuserpain = 0  ? ticket.pain == 0 : ticket.pain + (ticket.age * 0.02)/100
    # We need to get the sum of all current userpain scores and show it at the top of the page.
    @pains << ticket.matuserpain
    @total_pain = @pains.inject(:+)
    @tickets << ticket
    end
  # end
  return @tickets 
end

#TODO actually fetch the issues from an API call
@sprint = %w(OPS-1320,OPS-1456,OPS-1542,OPS-1545,OPS-1546,OPS-1547,OPS-1553, OPS-1290,OPS-1297,OPS-1486,OPS-1490,OPS-1548,OPS-1551,OPS-1556,OPS-1557,OPS-1558,OPS-1560,OPS-1561)

def fetch_sprint
  query = "issueKey in (#{@sprint.join(' ')})"
  uri = URI::encode("#{API_URI}/rest/api/2/search?jql=#{query}")
  query = open(uri, :http_basic_authentication => [API_USERNAME, API_PASS]).read
  result = JSON.parse(query)
  issues = result['issues']
  return issues
end
