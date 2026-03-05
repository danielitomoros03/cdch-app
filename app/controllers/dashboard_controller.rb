class DashboardController < ApplicationController
  # Authentication with Devise before any action
  before_action :authenticate_user!

  def index
    @calls_stats = build_stats_for(Call)
    @publications_stats = build_stats_for(Publication)
    @minutes_stats = build_stats_for(Minute)
    @users_stats = build_stats_for(User)
  end

  private

  def build_stats_for(model_class)
    scope = model_class.accessible_by(current_ability)
    now = Time.zone.now

    current_month_range = now.beginning_of_month..now.end_of_month
    previous_month = now.prev_month
    previous_month_range = previous_month.beginning_of_month..previous_month.end_of_month

    total_count = scope.count
    current_month_count = scope.where(created_at: current_month_range).count
    previous_month_count = scope.where(created_at: previous_month_range).count
    delta = current_month_count - previous_month_count

    {
      total: total_count,
      delta_text: delta_text_for(delta),
      delta_class: delta_class_for(delta),
      delta_icon: delta_icon_for(delta)
    }
  end

  def delta_text_for(delta)
    return "Sin cambios este mes" if delta.zero?

    prefix = delta.positive? ? "+" : ""
    "#{prefix}#{delta} este mes"
  end

  def delta_class_for(delta)
    return "text-info" if delta.zero?
    return "text-success" if delta.positive?

    "text-danger"
  end

  def delta_icon_for(delta)
    return "fa-minus" if delta.zero?
    return "fa-arrow-up" if delta.positive?

    "fa-arrow-down"
  end
end
