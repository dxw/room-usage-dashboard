module Helpers
  def gcal_fake_response(items)
    {
      "kind" => "calendar#events",
      "etag" => "test etag",
      "summary" => "test summary",
      "description" => "test description",
      "items" => items
    }.to_json
  end

  def gcal_fake_events_with_attendees
    [{
      "kind" => "calendar#event",
      "etag" => "sales etag",
      "id" => "sales test id",
      "summary" => "sales - pipeline",
      "description" => "sales meeting",
      "organizer" => {
        "email" => "sales@example.com",
        "displayName" => "Sales Person"
      },
      "start" => {
        "dateTime" => "2020-07-20T15:00:00+01:00"
      },
      "end" => {
        "dateTime" => "2020-07-20T15:30:00+01:00"
      },
      "attendees" => [
        {
          "email" => "attendee01@example.com",
          "displayName" => "Attendee 01",
          "responseStatus" => "accepted"
        },
        {
          "email" => "attendee02@example.com",
          "displayName" => "Attendee 02",
          "responseStatus" => "accepted"
        }
      ]
    }, {
      "kind" => "calendar#event",
      "etag" => "sales planning etag",
      "id" => "sales planning test id",
      "summary" => "sales - forward planning",
      "description" => "sales planning meeting",
      "organizer" => {
        "email" => "sales@example.com",
        "displayName" => "Sales Person"
      },
      "start" => {
        "dateTime" => "2020-07-20T15:30:00+01:00"
      },
      "end" => {
        "dateTime" => "2020-07-20T16:00:00+01:00"
      },
      "attendees" => [
        {
          "email" => "attendee01@example.com",
          "displayName" => "Attendee 01",
          "responseStatus" => "accepted"
        },
        {
          "email" => "attendee02@example.com",
          "displayName" => "Attendee 02",
          "responseStatus" => "accepted"
        }
      ]
    }]
  end

  def gcal_fake_events_without_attendees
    [{
      "kind" => "calendar#event",
      "etag" => "sales etag",
      "id" => "sales test id",
      "summary" => "sales - pipeline",
      "description" => "sales meeting",
      "organizer" => {
        "email" => "sales@example.com",
        "displayName" => "Sales Person"
      },
      "start" => {
        "dateTime" => "2020-07-20T15:00:00+01:00"
      },
      "end" => {
        "dateTime" => "2020-07-20T15:30:00+01:00"
      },
      "attendees" => []
    }, {
      "kind" => "calendar#event",
      "etag" => "sales planning etag",
      "id" => "sales planning test id",
      "summary" => "sales - forward planning",
      "description" => "sales planning meeting",
      "organizer" => {
        "email" => "sales@example.com",
        "displayName" => "Sales Person"
      },
      "start" => {
        "dateTime" => "2020-07-20T15:30:00+01:00"
      },
      "end" => {
        "dateTime" => "2020-07-20T16:00:00+01:00"
      },
      "attendees" => [
        {
          "email" => "attendee01@example.com",
          "displayName" => "Attendee 01",
          "responseStatus" => "declined"
        },
        {
          "email" => "attendee02@example.com",
          "displayName" => "Attendee 02",
          "responseStatus" => "declined"
        }
      ]
    }]
  end

  def gcal_fake_events_with_ongoing_meeting(start_time, end_time, second_start_time, second_end_time)
    [{
      "kind" => "calendar#event",
      "etag" => "sales etag",
      "id" => "sales test id",
      "summary" => "sales - pipeline",
      "description" => "sales meeting",
      "organizer" => {
        "email" => "sales@example.com",
        "displayName" => "Sales Person"
      },
      "start" => {
        "dateTime" => start_time
      },
      "end" => {
        "dateTime" => end_time
      },
      "attendees" => [
        {
          "email" => "attendee01@example.com",
          "displayName" => "Attendee 01",
          "responseStatus" => "accepted"
        },
        {
          "email" => "attendee02@example.com",
          "displayName" => "Attendee 02",
          "responseStatus" => "accepted"
        }
      ]
    }, {
      "kind" => "calendar#event",
      "etag" => "sales planning etag",
      "id" => "sales planning test id",
      "summary" => "sales - forward planning",
      "description" => "sales planning meeting",
      "organizer" => {
        "email" => "sales@example.com",
        "displayName" => "Sales Person"
      },
      "start" => {
        "dateTime" => second_start_time
      },
      "end" => {
        "dateTime" => second_end_time
      },
      "attendees" => [
        {
          "email" => "attendee01@example.com",
          "displayName" => "Attendee 01",
          "responseStatus" => "accepted"
        },
        {
          "email" => "attendee02@example.com",
          "displayName" => "Attendee 02",
          "responseStatus" => "accepted"
        }
      ]
    }]
  end

  def stub_gcal_request(body)
    stub_request(:any, /www.googleapis.com/)
      .to_return(body: body, headers: {"Content-Type" => "application/json"})
  end
end
