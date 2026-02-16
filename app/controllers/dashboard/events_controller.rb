module Dashboard
  class EventsController < ApplicationController
    before_action :set_event, only: %i[ show edit update destroy ]
    load_and_authorize_resource ## Authorization for Cancancan

    # GET /events or /events.json
    def index
      @events = Event.all.order(created_at: :desc)
    end

    # GET /events/1 or /events/1.json
    def show
    end

    # GET /events/new
    def new
      @event = Event.new
    end

    # GET /events/1/edit
    def edit
    end

    # POST /events or /events.json
    def create
      @event = Event.new(event_params)
      respond_to do |format|
        if @event.save
          format.html { redirect_to @event, notice: "Evento fue correctamente creado." }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /events/1 or /events/1.json
    def update
      respond_to do |format|
        if @event.update(event_params)
          format.html { redirect_to @event, notice: "Evento fue correctamente editado." }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /events/1 or /events/1.json
    def destroy
      @event.destroy!

      respond_to do |format|
        format.html { redirect_to events_path, status: :see_other, notice: "Evento fue correctamente eliminado." }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event
        @event = Event.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def event_params
        params.require(:event).permit(:title, :show_in, :active, :description, :kind, :day, :start_time, :end_time, :location, :content, :image)
      end
  end
end
