#!/usr/bin/env ruby
require ENV['TM_SUPPORT_PATH']+'/lib/exit_codes'

# method to return the users preference for a language's documentation location, or nil
def location *args
  args.each do |arg|
    env_string = "#{arg.upcase}_DOC_LOCATION"
    return ENV[env_string] if ENV[env_string]
  end
  nil
end

class Array
  # check if any item in the array matches the start of the given scope
  def has_match? tm_scope
    self.any? do |item|
      item == tm_scope[0..(item.length-1)]
    end
  end
end


base_url = nil
# loop through the scopes until we find a match, or run out.
ENV['TM_SCOPE'].split(" ").reverse.each do |scope|
  
  base_url = if %w[source.ruby.rails text.html.ruby text.haml].has_match? scope
    location("rails") || "http://railsapi.com/doc/rails-v2.3.2.1/?q=***"
  elsif %w[source.ruby].has_match? scope
    location("ruby") || "http://railsapi.com/doc/ruby-v1.8/?q=***"
  elsif %w[source.actionscript.3].has_match? scope
    location("as3", "flex4", "flex3", "flex2", "flex") || "http://beta.gotapi.com/as/?q=***"
  elsif %w[text.xml.mxml source.actionscript.3.embedded.mxml].has_match? scope
    location("flex4", "flex3", "flex2", "flex") ||  "http://beta.gotapi.com/flex/?q=***"
  elsif %w[text.html.basic source.css source.js].has_match? scope
    location("html") || "http://beta.gotapi.com/html/?q=***"
  elsif %w[source.java].has_match? scope
    location("java") || "http://beta.gotapi.com/java/?q=***"
  end
  
  # break out if we have made a match
  break if base_url
end

# revert to a default if necessary
base_url ||= location("default") || "http://beta.gotapi.com/?q=***"

# insert the search term into the url
url = base_url.gsub("***", ENV['TM_CURRENT_WORD'])

if ENV['OPEN_DOCS_IN_BROWSER']=="true"
  # use the mac open command to open with the browser
  `open #{url}`
else
  TextMate::exit_show_html "<meta http-equiv='Refresh' content='0;URL=#{url}'>"
end