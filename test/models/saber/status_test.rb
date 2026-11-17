require "test_helper"

class Saber::StatusTest < ActiveSupport::TestCase
  def status(**overrides)
    Saber::Status.new({ "ok" => true, "finished_at" => 2.days.ago.iso8601, "items" => 22_850,
                        "newest_datestamp" => 5.days.ago.iso8601 }.merge(overrides.stringify_keys))
  end

  test "a recent harvest that brings recent items has no warnings" do
    assert status.ok?
    assert_empty status.warnings
  end

  test "warns when Saber has delivered nothing new for more than a month" do
    quiet = status(newest_datestamp: Time.zone.parse("2026-07-07").iso8601)

    travel_to Time.zone.parse("2026-11-17 10:00") do
      assert quiet.quiet?
      assert_equal 133, quiet.quiet_days
      assert_match(/desde el 07\/07\/2026 \(hace 133 días\).*índice OAI/, quiet.warnings.join)
    end
  end

  test "warns when the weekly harvest stopped running" do
    late = status(finished_at: 20.days.ago.iso8601)

    assert late.late?
    assert_not late.ok?
    assert_match(/debía correr cada lunes/, late.warnings.join)
  end

  test "warns when the last harvest failed" do
    failed = status(ok: false, error: "getaddrinfo: nodename nor servname provided")

    assert_not failed.ok?
    assert_match(/falló: getaddrinfo/, failed.warnings.join)
  end
end
