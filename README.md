# status-dashboard

GOV.UK themed status dashboard for communicating manual message and service updates.

## In a nutshell
This dashboard is a Ruby on Rails application that makes use of [Turbo Streams](https://turbo.hotwired.dev/handbook/introduction#turbo-streams%3A-deliver-live-page-changes) to broadcast updates over Websocket to all connected clients.

The public dashboard is configured to send ETags and send a new fresh copy only when there is an update since the user last visited it.

Redis for streaming (ActionCable) and Postgres for persistance are required, but could easily be swapped with something more suitable to any context.

```
+---------------+
|     Server    |
+---------------+
|               |
| 1. Update     |
| Message/      |
|   Service     |
|               |
+-------+-------+
        |
        | 2. Broadcast update
        |    over WebSocket
        |    (ActionCable)
        v
+---------------+
|     Redis     |
| (Streaming)   |
+---------------+
        |
        | 3. Deliver update
        |    over WebSocket
        v
+---------------+
|    Clients    |
|  (Browsers)   |
+---------------+
|               |
| 4. Receive    |
|    update     |
|    (Turbo     |
|    Streams)   |
|               |
+---------------+
```

## Current live use

I created this dashboard as a spike project in my own free time while I was working at the Legal Aid Agency (UK) and later used it as a starting point to customise it further and deploy it for every delivery manager to use at work.

The context is that I was trying to migrate another older spike project from Firebase to AWS (which required substantial rewrite, see [here](https://github.com/ministryofjustice/laa-service-status-dashboard/pull/36)), but eventually decided to rewrite it in Rails and deploy it to the MoJ Cloud Platform using Kubernetes. The whole process took only a few weeks.

The final iteration of this dashboard is currently embedded at: https://portal.legalservices.gov.uk/

## How to run and customise

You can use this project a starting point, make sure to look for `CHANGEME` across the codebase and see what changes would be required.

You can easily swap out the frontend as well.

### Running locally

Using docker:

```sh
$ docker-compose up --build dashboard
```

Then visit http://0.0.0.0:3000/ and http://0.0.0.0:3000/admin

Use `admin@changeme.com / DummyDummyPwd01` for the test admin user.

---

If you want to run this locally, just grab the correct [Ruby version](/.ruby-version) and run:

```sh
$ bundle install && yarn install
```

Build assets using:

```sh
$ yarn build && yarn build:css
```

### Running tests

Using docker:

```sh
$ docker-compose run --build --rm test
```

Or locally:

```sh
$ bundle exec rspec
```

### Deployment

Example YAML files for Kubernetes deployment are provided under the [k8s/](./k8s) folder.

### Monitoring

Sentry is installed and can be configured setting the correct `SENTRY_DSN` environment variable.

Prometheus metrics collector installed but requires further configuration, i.e. creation of the `/metrics` endpoint.
