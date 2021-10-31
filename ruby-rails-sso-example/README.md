# rails-sso-example

An example Ruby on Rails application demonstrating how SSO works with WorkOS and Rails.
The application is built with Rails 6 and Bootstrap with Webpack, and also uses Devise.

## Get Started

### Requirements

- Ruby 2.6
- Rails 6
- Foreman gem

### Clone, install and migrate the database

```bash
git clone https://github.com/workos-inc/ruby-example-applications.git
cd ruby-example-applications/ruby-rails-sso-example
bundle install
yarn install --check-files
rails db:migrate
```

## Set up SSO Connection with WorkOS

Use the [WorkOS documentation](https://workos.com/docs/sso/guide/introduction) to set up an SSO connection with your identity provider of choice.

### Setup in the WorkOS Dashboard

You'll need to create an [Organization](https://dashboard.workos.com/organizations) and an SSO Connection in the Organization in your WorkOS Dashboard. Additionally, add a [Redirect URI](https://dashboard.workos.com/configuration) with the value `http://localhost:5000/sso/callback`.

### Setup environment variables

Run `cp .env.example .env` and add your [API Key](https://dashboard.workos.com/api-keys) and [Client ID](https://dashboard.workos.com/configuration). The `workos` gem will read your API key from the ENV variable `WORKOS_API_KEY` and your Client ID from the ENV variable `WORKOS_CLIENT_ID`. You may also set the API key and Client ID yourself by adding `WorkOS.key = $YOUR_API_KEY` and `CLIENT_ID = $YOUR_CLIENT_ID` to `sessions_controller.rb`.

## Run the application and sign in using SSO

Start the server:
```bash
foreman start -f Procfile.dev
```

### Application Flow

- Head to `http://localhost:5000`
- If you're not authenticated, the site will re-direct to `http://localhost:5000/users/sign_in`
- Here you can authenticate with Username/Password, or with the SSO you set up with WorkOS
- To authenticate with SSO, input the domain you used to set up your WorkOS connection, and select the `Sign in with SSO` button
- After successfully authenticating, you should see a JSON print out of your user information

For more information, see the [WorkOS Ruby SDK documentation](https://docs.workos.com/sdk/ruby).
