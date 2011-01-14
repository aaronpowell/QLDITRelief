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
	email = email.downcase
	docs = options.db.view('people/sponsors_by_email', :key => h(email))
	if docs['rows'].length > 0
		haml :alreadyRegistered
	else
		options.db.save_doc({ 
			'companyName' => params[:name],
			'email' => email,
			'contactName' => params[:contact],
			'dateCreated' => Time.now.to_s
		})
		
		Pony.mail(:to => email,
					:from => "info@dddsydney.com",
					:subject => "DDD Sydney Sponsorship Information",
					:html_body => "<p>Thanks for your interest in sponsoring DDD Sydney. Please find a sponsorship package attached for your reference. </p> <p>If you have any questions, simply reply to this email. </p> <p> Thanks, <br /> The DDD Sydney Team </p>",
					:attachments => {"DDD Sydney Sponsor Pack.docx" => File.read("doco/DDD Sydney Sponsor Pack.docx")},
					:port => '587',
					:via => :smtp,
					:via_options => { 
						:address              => 'smtp.sendgrid.net', 
						:port                 => '587', 
						:enable_starttls_auto => true, 
						:user_name            => ENV['SENDGRID_USERNAME'], 
						:password             => ENV['SENDGRID_PASSWORD'], 
						:authentication       => :plain, 
						:domain               => ENV['SENDGRID_DOMAIN']
					})
	end
end