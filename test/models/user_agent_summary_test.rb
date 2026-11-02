require "test_helper"

class UserAgentSummaryTest < ActiveSupport::TestCase
  test "recognizes the usual systems and browsers" do
    {
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15" => [ "macOS", "Safari 18" ],
      "Mozilla/5.0 (Linux; Android 14; SM-A546E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Mobile Safari/537.36" => [ "Android 14", "Chrome 129" ],
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:131.0) Gecko/20100101 Firefox/131.0" => [ "Linux", "Firefox 131" ],
      "curl/8.4.0" => [ "Otro", "Programa automático" ]
    }.each do |agent, expected|
      assert_equal expected, UserAgentSummary.parse(agent).to_a, agent
    end
    assert_equal [ nil, nil ], UserAgentSummary.parse(nil).to_a
  end
end
