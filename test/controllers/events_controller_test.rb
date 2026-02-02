require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:one)
  end

  test "should get index" do
    get events_index_url
    assert_response :success
  end

  test "should get new" do
    get new_events_url
    assert_response :success
  end

  test "should create event" do
    assert_difference("Event.count") do
      post events_index_url, params: { event: { active: @event.active, day: @event.day, description: @event.description, end_time: @event.end_time, location: @event.location, show_in: @event.show_in, start_time: @event.start_time, title: @event.title, kind: @event.kind } }
    end

    assert_redirected_to event_url(Event.last)
  end

  test "should show event" do
    get event_url(@event)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_url(@event)
    assert_response :success
  end

  test "should update event" do
    patch event_url(@event), params: { event: { active: @event.active, day: @event.day, description: @event.description, end_time: @event.end_time, location: @event.location, show_in: @event.show_in, start_time: @event.start_time, title: @event.title, type: @event.type } }
    assert_redirected_to event_url(@event)
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_index_url
  end
end
