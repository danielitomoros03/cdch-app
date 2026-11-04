module TeacherSpace
  # Las publicaciones de Saber que se le atribuyen al docente (marco Turbo en "Mi espacio"):
  # las filtra por tipo y año y corrige las ajenas. "No es mía" la quita de su perfil y evita
  # que la cosecha vuelva a vincularla; "sí es mía" lo deshace.
  class SaberAuthorshipsController < BaseController
    before_action :require_teacher
    before_action :set_authorship, only: %i[reject restore]

    def index
      @list = SaberPublicationList.new(current_teacher.saber_authorships.accepted, kind: params[:tipo], year: params[:anio], page: params[:page])
      @rejected = current_teacher.saber_authorships.rejected.joins(:saber_item).merge(SaberItem.current).includes(:saber_item)
    end

    def reject
      @authorship.update!(rejected_at: Time.current)
      Audit.record(:saber_authorship_rejected, item: @authorship, sensitive: false)
      redirect_to saber_authorships_path(list_params), notice: "Listo: «#{@authorship.audit_label}» ya no aparece en tu perfil."
    end

    def restore
      @authorship.update!(rejected_at: nil)
      Audit.record(:saber_authorship_restored, item: @authorship, sensitive: false)
      redirect_to saber_authorships_path(list_params), notice: "Listo: «#{@authorship.audit_label}» vuelve a tu perfil."
    end

    private

    # Solo las suyas: con otro id responde 404.
    def set_authorship
      @authorship = current_teacher.saber_authorships.find(params[:id])
    end

    # Al volver, la lista sigue con los mismos filtros y en la misma página.
    def list_params
      params.permit(:tipo, :anio, :page).to_h
    end
  end
end
