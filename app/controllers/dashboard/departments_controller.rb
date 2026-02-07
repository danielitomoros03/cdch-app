module Dashboard
  class DepartmentsController < ApplicationController
  before_action :set_department, only: %i[ show edit update destroy ]

  # GET /dashboard/departments or /dashboard/departments.json
  def index
    @departments = Department.all.order(created_at: :desc)
  end

  # GET /dashboard/departments/1 or /dashboard/departments/1.json
  def show
  end

  # GET /dashboard/departments/new
  def new
    @department = Department.new
  end

  # GET /dashboard/departments/1/edit
  def edit
  end

  # POST /dashboard/departments or /dashboard/departments.json
  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.html { redirect_to @department, notice: "Department was successfully created." }
        format.json { render :show, status: :created, location: @department }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dashboard/departments/1 or /dashboard/departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to @department, notice: "Departamento actualizado correctamente." }
        format.json { render :show, status: :ok, location: @department }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dashboard/departments/1 or /dashboard/departments/1.json
  def destroy
    @department.destroy!

    respond_to do |format|
      format.html { redirect_to departments_path, status: :see_other, notice: "Departamento eliminado correctamente." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def department_params
      params.require(:department).permit(:name, :acronym, :organize, :description, :logoDepartment)
    end
  end
end
