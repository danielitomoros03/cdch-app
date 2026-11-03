require "test_helper"

class BackupStatusTest < ActiveSupport::TestCase
  test "a recent backup without errors is up to date" do
    status = BackupStatus.new("db_at" => 2.hours.ago.iso8601, "db_size" => 3_000_000, "error" => "")
    assert status.ok?
  end

  test "an error or a backup older than a day and a half needs attention" do
    assert_not BackupStatus.new("db_at" => 2.hours.ago.iso8601, "error" => "El respaldo de la base salió vacío.").ok?
    assert BackupStatus.new("db_at" => 2.days.ago.iso8601, "error" => "").stale?
    assert BackupStatus.new("db_at" => "", "error" => "").stale?
  end
end
