# because we;e usign Ruy 1.8 we need to require rubygems if we're going to use gems.
require 'rubygems'
# we want a radical stylization
require 'haml'
# we need a web server. We're using the sinatra gem girl!
require 'sinatra'

require './lib/jira.rb'

# when a user goes to the root of the app, jiralicious.eol.org, they will see a list of JIRA issues.
get '/' do
  # We need to sort issues by userpain
  issues = fetch_issues
  @issues = issues.sort_by { |a| [ a.matuserpain ] }
  puts issues.class
  # render results to browser
  haml :index, :locals => {:issues => @issues}
end

