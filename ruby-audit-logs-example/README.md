# ruby-audit-logs-example

An example Ruby application demonstrating how to use the [WorkOS Ruby SDK](https://github.com/workos/workos-ruby) to send and retrieve Audit Log events. This example is not meant to show a real-world example of an Audit Logs implementation, but rather to show concrete examples of how events can be sent using the Ruby SDK.

## Clone and Install

1. Clone the main repo:

   ```sh
   # HTTPS
   $ git clone https://github.com/workos/ruby-example-applications.git
   ```

2. Navigate to the Audit Logs example app within the cloned repo and install dependencies:

   ```sh
   $ cd ruby-example-applications/ruby-audit-logs-example && bundle install
   ```

## Configure your environment

1. Grab your [API Key](https://dashboard.workos.com/api-keys) and your [Client ID](https://dashboard.workos.com/configuration).
2. Run `cp .env.example .env` and add your API key and Client ID. The `workos` gem will read your API key from the ENV variable `WORKOS_API_KEY` and your Client ID from the ENV variable `WORKOS_CLIENT_ID`. You may also set the API key and Client ID yourself by adding `WorkOS.key = $YOUR_API_KEY` and `CLIENT_ID = $YOUR_CLIENT_ID` to `app.rb`.

### Audit Logs Setup with WorkOS

1. Follow the [Audit Logs configuration steps](https://workos.com/docs/audit-logs/emit-an-audit-log-event/sign-in-to-your-workos-dashboard-account-and-configure-audit-log-event-schemas) to set up the following 5 events that are sent with this example:

Action title: "user.signed_in" | Target type: "team"
Action title: "user.logged_out" | Target type: "team"
Action title: "user.organization_set" | Target type: "team"
Action title: "user.organization_deleted" | Target type: "team"
Action title: "user.connection_deleted" | Target type: "team"

2. Next, take note of the Organization ID for the Org which you will be sending the Audit Log events for. This ID gets entered into the splash page of the example application.

3. Once you enter the Organization ID and submit it, you will be brought to the page where you'll be able to send the audit log events that were just configured. You'll also notice that the action of setting the Organization triggered an Audit Log already. Click the buttons to send the respective events.

4. To obtain a CSV of the Audit Log events that were sent for the last 30 days, click the "Export Events" button. This will bring you to a new page where you can download the events. Downloading the events is a 2 step process. First you need to create the report by clicking the "Generate CSV" button. Then click the "Access CSV" button to download a CSV of the Audit Log events for the selected Organization for the past 30 days.

## Run the app

```sh
ruby app.rb
```

## Audit Logs Setup with WorkOS

5. Follow the [Audit Logs configuration steps](https://workos.com/docs/audit-logs/emit-an-audit-log-event/sign-in-to-your-workos-dashboard-account-and-configure-audit-log-event-schemas) to set up the following 2 events that are sent with this example:

Action title: "user.organization_set" | Target type: "team"
Action title: "user.organization_deleted" | Target type: "team"

6. Configure the Admin Portal Redirect URI.

Navigate to the Configuration tab in your WorkOS Dshboard. From there click the Admin Portal tab. Click the Edit Admin Portal Redirect Links button and add "http://localhost:8000" to the "When clicking the back navigation, return users to:" input, then click Save Redirect Links.

7. To obtain a CSV of the Audit Log events that were sent for the last 30 days, click the "Export Events" tab. This will bring you to a new page where you can download the events. Downloading the events is a 2 step process. First you need to create the report by clicking the "Generate CSV" button. Then click the "Access CSV" button to download a CSV of the Audit Log events for the selected Organization for the past 30 days. You may also adjust the time range using the form inputs.

## Need help?

If you get stuck and aren't able to resolve the issue by reading our API reference or tutorials, you can reach out to us at support@workos.com and we'll lend a hand.
