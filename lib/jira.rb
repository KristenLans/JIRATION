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
end



def fetch_issues(project='all')
  @available_projects = %w(WEB DATA)
  unless @available_projects.include? project
    project = @available_projects.join(",")
  end
  # uri = URI::encode("#{@api_uri}/rest/api/2/search?jql=project in (#{project}) AND (issuetype = \"Agile bug\" OR issuetype = Bug) AND status in (Open, \"In Progress\", Reopened, \"Needs More Information\")&maxResults=100&fields&expand")
  query = "project in (DATA) AND issuetype in (Bug, 'Agile bug') AND status in (Open, 'In Progress', Reopened, 'Needs More Information')&maxResults=100&fields&expand"
  uri = URI::encode("#{@api_uri}/rest/api/2/search?jql=#{query}")
  puts uri
  # uri = "https://jira.eol.org/rest/api/2/search?jql=project%20in%20(#{project})%20AND%20issuetype%20in%20(Bug,%20'Agile%20bug')%20AND%20status%20in%20(Open,%20'In%20Progress',%20Reopened,%20'Needs%20More%20Information')&maxResults=100&fields&expand"
  # open(uri, :http_basic_authentication => [@api_username, @api_pass]){|f| ap f.meta  }
  query = open(uri, :http_basic_authentication => [@api_username, @api_pass]).read
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
    unless issue['fields'][@seriousness].nil? || issue['fields'][@impact].nil? || issue['fields'][@urgency].nil?
      seriousness = issue['fields'][@seriousness]['value'].chars.first.to_i
      impact = issue['fields'][@impact]['value'].chars.first.to_i
      urgency = issue['fields'][@urgency]['value'].chars.first.to_i
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
      ticket.issue_link = "https://jira.eol.org/browse/#{ticket.key}"
      #userpain with maturity
      ticket.matuserpain = ticket.pain + (ticket.age * 0.02)/100
    # We need to get the sum of all current userpain scores and show it at the top of the page.
    @pains << ticket.matuserpain
      @tickets << ticket
    end
  end
  # return @tickets
  return issues
  # return @tickets
  
end

ap fetch_issues('DATA')