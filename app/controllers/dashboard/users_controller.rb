module Dashboard
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy]

    def index
      @users = User.order(:lastname, :name)
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
        format.html { redirect_to users_path, status: :see_other, notice: 'Usuario eliminado.' }
        format.json { head :no_content }
      end
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
        :number_phone,
        :password,
        :password_confirmation
      )
    end
  end
end
