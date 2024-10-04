apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-development
  namespace: status-dashboard-development
spec:
  replicas: 1
  selector:
    matchLabels:
      app: status-dashboard-development
  template:
    metadata:
      labels:
        app: status-dashboard-development
    spec:
      containers:
      - name: webapp
        image: ${ECR_URL}:${IMAGE_TAG}
        ports:
        - containerPort: 3000
        env:
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: url
          - name: REDIS_URL
            valueFrom:
              secretKeyRef:
                name: elasticache-redis
                key: url
          - name: SECRET_KEY_BASE
            valueFrom:
              secretKeyRef:
                name: application-secrets
                key: secret-key-base
          - name: RAILS_MASTER_KEY
            valueFrom:
              secretKeyRef:
                name: application-secrets
                key: rails-master-key
          - name: GOVUK_NOTIFY_API_KEY
            valueFrom:
              secretKeyRef:
                name: application-secrets
                key: govuk-notify-api-key
          - name: SENTRY_DSN
            valueFrom:
              secretKeyRef:
                name: application-secrets
                key: sentry-dsn
          - name: RAILS_ENV
            value: development
          - name: RAILS_DEVELOPMENT_HOSTS
            value: https://<CHANGEME>
          - name: DOMAIN_URL
            value: https://<CHANGEME>
          - name: RAILS_LOG_TO_STDOUT
            value: present
          - name: LOG_LEVEL
            value: debug
