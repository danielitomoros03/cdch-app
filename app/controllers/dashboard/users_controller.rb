module Dashboard
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy]
    before_action :set_collections, only: %i[new create edit update]
    load_and_authorize_resource ## Authorization for Cancancan

    def index
      @users = User.accessible_by(current_ability).order(created_at: :desc)
    end

    def show
    end

    def new
      @user = User.new
    end

    def edit
    end

    def create
      create_params = user_params
      resource_permissions = extract_resource_permissions(resource_permissions_params) if superadmin_role?
      @selected_resource_permissions = resource_permissions if superadmin_role?
      @user = User.new(create_params)

      respond_to do |format|
        if @user.save
          sync_user_permissions(@user, resource_permissions) if superadmin_role?
          format.html { redirect_to users_path, notice: 'Usuario creado correctamente.' }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      up_params = user_params
      resource_permissions = extract_resource_permissions(resource_permissions_params) if superadmin_role?
      @selected_resource_permissions = resource_permissions if superadmin_role?

      if up_params[:password].blank?
        up_params = up_params.except(:password, :password_confirmation)
      end
      if up_params[:photoUser].blank?
        up_params = up_params.except(:photoUser)
      end

      respond_to do |format|
        if @user.update(up_params)
          sync_user_permissions(@user, resource_permissions) if superadmin_role?
          format.html { redirect_to users_path, notice: 'Usuario actualizado correctamente.' }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_path, status: :see_other, notice: 'Usuario eliminado correctamente.' }
        format.json { head :no_content }
      end
    end

    # Edit o create their department and job title lists
    def set_collections
      @available_resources = UserPermission::RESOURCE_MAP.keys
      @available_permission_actions = UserPermission::ACTION_MAP.keys

      if superadmin_role?
        @departments = Department.all
        @job_titles = JobTitle.all
      else
        @departments = Department.where(id: current_user.department_id)
        # Limit job titles to those with role less than or equal to current user's role
        current_role_value = JobTitle.roles[current_user.role]
        @job_titles = JobTitle.where("role <= ?", current_role_value)
      end

      return unless defined?(@user) && @user.present?

      @departments = @departments.or(Department.where(id: @user.department_id))
      @job_titles = @job_titles.or(JobTitle.where(id: @user.job_title_id))
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted_params = params.require(:user).permit(
        :email,
        :name,
        :lastname,
        :identification_number,
        :job_title_id,
        :department_id,
        :number_phone,
        :photoUser,
        :password,
        :password_confirmation,
        resource_permissions: []
      )

      permitted_params.except(:resource_permissions)

    end

    def resource_permissions_params
      params.fetch(:user, {}).permit(resource_permissions: [])[:resource_permissions]

    end

    def extract_resource_permissions(permissions)
      Array(permissions)
        .reject(&:blank?)
        .select { |permission| UserPermission.valid_token?(permission) }
        .uniq
    end

    def sync_user_permissions(user, resources)
      if resources.empty?
        user.user_permissions.destroy_all
        return
      end

      user.user_permissions.where.not(resource: resources).destroy_all
      existing_resources = user.user_permissions.pluck(:resource)

      (resources - existing_resources).each do |resource|
        user.user_permissions.create(resource: resource)
      end
    end

    def superadmin_role?
      role_name = current_user.role.is_a?(Integer) ? JobTitle.roles.key(current_user.role) : current_user.role.to_s
      department_acronym = current_user.department&.acronym.to_s.strip.upcase

      role_name == "Superadmin" || (role_name == "JefeDepartamento" && department_acronym == "DTIC")
    end
  end
end

