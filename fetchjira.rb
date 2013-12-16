# because we;e usign Ruy 1.8 we need to require rubygems if we're going to use gems.
require 'rubygems'
# we want a radical stylization
require 'haml'
# we need a web server. We're using the sinatra gem girl!
require 'sinatra'
# we need to render Johnsons
require 'json'
require './lib/jira.rb'

# when a user goes to the root of the app, issues.eol.org, they will see a list of JIRA issues.
get '/' do
  # We need to sort issues by userpain
  issues = fetch_issues(params[:project] || "all")
  @issues = issues.sort_by { |a| [ a.matuserpain ] }
  @project = params[:project] ||= "All"
  # render results to browser
  haml :index, :locals => {:issues => @issues, :project => @project}
end


# We need to output issue key, pain, and age in JSON
get '/scatterplot.json' do
  content_type :json
  @issues = fetch_issues #todo support separate projects
  @issues.select{|issue| not issue.pain.nil? }.map{|issue| { :jira_key => issue.jira_key, :pain => issue.pain, :age => issue.age} }.to_json
end

# We need to plot age vs pain in a scatterplot graph


# Show this graph on the page, Girl!
get '/graph' do #todo support separate projects
  haml :scatterplot, :locals => {:issues => fetch_issues}
end

get '/api' do
  # need to output issue counts and avg userpain
  jiration_stats.to_json
end