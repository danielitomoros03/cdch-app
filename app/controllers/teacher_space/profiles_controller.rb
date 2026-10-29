module TeacherSpace
  # La ficha del docente vista por él mismo: sus datos (editables), su cargo en la UCV y
  # su historia en el CDCH, sin montos, evaluaciones, observaciones internas ni arbitrajes.
  class ProfilesController < BaseController
    before_action :require_teacher

    def show
      @profile = TeacherProfile.for(current_teacher)
      load_history
    end

    def update
      @profile = TeacherProfile.new(current_teacher, profile_params)
      if @profile.save
        redirect_to teacher_space_path, notice: "Guardamos tus datos."
      else
        load_history
        render :show, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:teacher_profile).permit(:email, :phone, :orcid, :research_lines)
    end

    def load_history
      person = current_teacher
      @faculty_names = Faculty.pluck(:code, :name).to_h
      @appointments = person.ucv_appointments.order(hired_on: :desc)
      @history = TeacherHistory.new(person)
    end
  end
end
