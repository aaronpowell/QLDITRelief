['rubygems', 'sinatra', 'haml', 'pony', 'couchrest'].each {|gem| require gem}
require 'sinatra/reloader' if development?

if ENV['CLOUDANT_URL']
  set :db, CouchRest.database!( ENV['CLOUDANT_URL'] + '/qlditrelief' )
else
  set :db, CouchRest.database!( 'http://localhost:5984/qlditrelief' )
end

helpers do
  include Rack::Utils

  def h(source)
    escape_html(source).gsub(' ', '%20')
  end

end

set :haml, :format => :html5

get '/' do
	haml :index
end

get '/donate' do
	haml :donate
end

post '/donate' do
	
end