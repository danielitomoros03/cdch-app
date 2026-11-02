# Registro en la bitácora de lo que no es un cambio en un modelo (entradas, bloqueos,
# exportaciones) o que conviene resumir en una sola línea (los permisos de un usuario,
# los datos que corrige un docente). Los cambios en modelos los guarda PaperTrail solo,
# con el contexto que deja ApplicationController#info_for_paper_trail.
module Audit
  module_function

  # Desde dónde y con qué: IP, ubicación aproximada, sistema operativo y navegador.
  def request_context(request)
    agent = UserAgentSummary.parse(request.user_agent)
    { ip: request.remote_ip, location: GeoLocator.lookup(request.remote_ip),
      os: agent.os, browser: agent.browser, request_id: request.request_id }
  end

  def actor_info(actor)
    case actor
    when User then { whodunnit: actor.id.to_s, actor_type: "User", actor_label: user_label(actor) }
    when Person then { whodunnit: actor.id.to_s, actor_type: "Person", actor_label: "#{actor.display_name} (docente)" }
    else { whodunnit: nil, actor_type: nil, actor_label: nil }
    end
  end

  def user_label(user)
    acronym = user.department&.acronym
    acronym.present? ? "#{user.full_name} (#{acronym})" : user.full_name
  end

  # Sin `request`, toma quién y desde dónde de la petición en curso (lo que dejó el
  # controlador en PaperTrail). Con `request`, el actor se pasa aparte (o nadie).
  def record(event, item: nil, details: {}, sensitive: true, actor: nil, request: nil)
    who_and_where = if request
      request_context(request).merge(actor_info(actor))
    else
      PaperTrail.request.controller_info.to_h.merge(whodunnit: PaperTrail.request.whodunnit&.to_s)
    end

    AuditVersion.create!(
      event: event.to_s, item_type: item&.class&.base_class&.name, item_id: item&.id,
      item_label: item&.audit_label, details: details, sensitive: sensitive, **who_and_where.symbolize_keys
    )
  end
end
