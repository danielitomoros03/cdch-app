module Dashboard
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy]
    before_action :set_collections, only: %i[new create edit update]
    load_and_authorize_resource ## Authorization for Cancancan

    def index
      @users = User.all.order(created_at: :desc)
    end

    def show
    end

    def new
      @user = User.new
    end

    def edit
    end

    def create
      @user = User.new(user_params)

      respond_to do |format|
        if @user.save
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
      if up_params[:password].blank?
        up_params = up_params.except(:password, :password_confirmation)
      end
      if up_params[:photoUser].blank?
        up_params = up_params.except(:photoUser)
      end

      respond_to do |format|
        if @user.update(up_params)
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
      if current_user.role == "Superadmin" || current_user.role == 3
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
      params.require(:user).permit(
        :email,
        :name,
        :lastname,
        :identification_number,
        :job_title_id,
        :department_id,
        :number_phone,
        :photoUser,
        :password,
        :password_confirmation
      )
      end
    end
  end

