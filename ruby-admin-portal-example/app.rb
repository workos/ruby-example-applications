require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'

$organization

get '/' do

    erb :index
end

post '/provision-enterprise' do
    domains = params['domain'].split(" ")
    organizationName = params['org']
#    if an organization does exist with the domain, use that organization for connection
    organizations = WorkOS::Organizations.list_organizations(
        domains: domains
      )
    if organizations.data.length == 0 
        $organization = WorkOS::Organizations.create_organization(
            name: organizationName,
            domains: domains
        )
    else
        $organization = organizations.data[0]
    end
    erb :admin_portal_launcher
end


get('/launch-admin-portal') do
    intent = params["intent"]
    organization_id = $organization.id  # ... The ID of the organization to start an Admin Portal session for
    portal_link = WorkOS::Portal.generate_link(
      organization: organization_id,
      intent: intent,
    ) 
    redirect portal_link
end