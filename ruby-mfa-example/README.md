# ruby-mfa-example

An example Sinatra application demonstrating how MFA works with WorkOS and Ruby.

## Clone and Install

1. Clone the main repo:

```sh
git clone https://github.com/workos/ruby-example-applications.git
```

2. Navigate to the MFA app within the main repo and install dependencies:

```sh
cd ruby-example-applications/ruby-mfa-example && bundle install
```

## Configure your environment

1. Grab your [API Key](https://dashboard.workos.com/api-keys) and your [Client ID](https://dashboard.workos.com/configuration).
2. Run `cp .env.example .env` and add your API key and Client ID. The `workos` gem will read your API key from the ENV variable `WORKOS_API_KEY` and your Client ID from the ENV variable `WORKOS_CLIENT_ID`. You may also set the API key and Client ID yourself by adding `WorkOS.key = $YOUR_API_KEY` and `CLIENT_ID = $YOUR_CLIENT_ID` to `app.rb`.

## Run the app 

```sh
ruby app.rb
```

Head to `http://localhost:4567`

When testing SMS use the {{code}} parameter in your string as well as whatever other message details that you'd like to send as this will generate a random code that the user can verify

For more information, see the [WorkOS Ruby SDK documentation](https://docs.workos.com/sdk/ruby).
