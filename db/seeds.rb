# frozen_string_literal: true

User.create!(
  {
    name: 'Support',
    email: 'admin@changeme.com',
    confirmed_at: DateTime.now,
    admin: true,
    password: 'DummyDummyPwd01',
    password_confirmation: 'DummyDummyPwd01'
  }
)

updated_by = User.find_by(email: 'admin@changeme.com')

Message.create!(body: "This is an external message", scope: :external, updated_by:)
Message.create!(body: "This is an internal message", scope: :internal, updated_by:)

Service.create!(
  [
    {
      name: 'Apply For Legal Aid',
      status: 'Good Service',
      scope: 'external',
      hidden: false,
      updated_by:,
      skip_broadcast_changes: true
    },
    {
      name: 'CCMS',
      status: 'Scheduled Outage',
      scope: 'external',
      hidden: false,
      updated_by:,
      skip_broadcast_changes: true
    },
    {
      name: 'CWA',
      status: 'Minor Issues',
      scope: 'external',
      hidden: false,
      updated_by:,
      skip_broadcast_changes: true
    },
    {
      name: 'eForms',
      status: 'Severe Issues',
      scope: 'external',
      hidden: false,
      updated_by:,
      skip_broadcast_changes: true
    },
    {
      name: 'LAA Online Portal',
      status: 'Good Service',
      scope: 'external',
      hidden: false,
      destroyable: false,
      mirrorable: true,
      updated_by:,
      skip_broadcast_changes: true
    },
    {
      name: 'OBIEE',
      status: 'Good Service',
      scope: 'external',
      hidden: true,
      updated_by:,
      skip_broadcast_changes: true
    }
  ]
)
