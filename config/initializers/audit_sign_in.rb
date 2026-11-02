# Bitácora de entradas al panel: las que funcionan, las fallidas y los bloqueos de cuenta.
# Warden corre fuera de los controladores, así que el contexto sale de la petición.

Warden::Manager.after_authentication do |user, auth, _opts|
  next unless user.is_a?(User)

  remembered = auth.winning_strategy.is_a?(Devise::Strategies::Rememberable)
  Audit.record(remembered ? :sign_in_remembered : :sign_in, item: user, actor: user,
               request: ActionDispatch::Request.new(auth.env), sensitive: false)
end

Warden::Manager.before_failure do |env, opts|
  request = ActionDispatch::Request.new(env)
  email = request.params.dig("user", "email").to_s.strip.downcase
  next unless opts[:scope] == :user && request.post? && email.present?

  user = User.find_for_authentication(email: email)
  # El intento que bloquea la cuenta es el único que llega con un bloqueo recién puesto.
  if opts[:message] == :locked && user&.locked_at&.after?(10.seconds.ago)
    Audit.record(:account_locked, item: user, request: request, details: { email: email, attempts: Devise.maximum_attempts })
  else
    Audit.record(:sign_in_failed, item: user, request: request, details: { email: email, reason: opts[:message].to_s })
  end
end
