# Sistema operativo y navegador legibles a partir del User-Agent. Basta con reconocer los
# que se usan de verdad; lo demás queda como "Otro".
UserAgentSummary = Struct.new(:os, :browser) do
  def self.parse(user_agent)
    agent = user_agent.to_s
    return new(nil, nil) if agent.blank?

    new(os_for(agent), browser_for(agent))
  end

  def self.os_for(agent)
    case agent
    when /Windows NT 10\.0/ then "Windows 10 u 11"
    when /Windows NT 6\.3/ then "Windows 8.1"
    when /Windows NT 6\.1/ then "Windows 7"
    when /Windows/ then "Windows"
    when /Android (\d+)/ then "Android #{$1}"
    when /iPad.*? OS (\d+)_/ then "iPadOS #{$1}"
    when /iPhone.*? OS (\d+)_/ then "iOS #{$1}"
    when /CrOS/ then "ChromeOS"
    when /Mac OS X/ then "macOS"
    when /Linux/ then "Linux"
    else "Otro"
    end
  end

  def self.browser_for(agent)
    case agent
    when /bot|crawler|spider|curl|wget|python|ruby|java\//i then "Programa automático"
    when /Edg(?:e|A|iOS)?\/(\d+)/ then "Edge #{$1}"
    when /OPR\/(\d+)/ then "Opera #{$1}"
    when /SamsungBrowser\/(\d+)/ then "Samsung Internet #{$1}"
    when /(?:Firefox|FxiOS)\/(\d+)/ then "Firefox #{$1}"
    when /(?:Chrome|CriOS)\/(\d+)/ then "Chrome #{$1}"
    when /Version\/(\d+)[\d.]* (?:Mobile\/\S+ )?Safari/ then "Safari #{$1}"
    else "Otro"
    end
  end
end
