Message.create!(body: "This is an external message", scope: :external)
Message.create!(body: "This is an internal message", scope: :internal)

Service.create!(
  [
    {
      name: "Apply For Legal Aid",
      status: "Good Service",
      scope: "external",
      hidden: false,
      skip_broadcast_changes: true
    },
    {
      name: "CCMS",
      status: "Scheduled Outage",
      scope: "external",
      hidden: false,
      skip_broadcast_changes: true
    },
    {
      name: "CWA",
      status: "Minor Issues",
      scope: "external",
      hidden: false,
      skip_broadcast_changes: true
    },
    {
      name: "eForms",
      status: "Severe Issues",
      scope: "external",
      hidden: false,
      skip_broadcast_changes: true
    },
    {
      name: "LAA Online Portal",
      status: "Good Service",
      scope: "external",
      hidden: false,
      destroyable: false,
      mirrorable: true,
      skip_broadcast_changes: true
    },
    {
      name: "OBIEE",
      status: "Good Service",
      scope: "external",
      hidden: true,
      skip_broadcast_changes: true
    }
  ]
)
