class Api::V1::Admin::DashboardController < Api::V1::AdminController

  def statistics_info
    total_users = User.all.size
    total_paid_users = '-'
    total_generated_user = User.joins(conversations: :ai_calls).distinct.count
    total_images = AiCall.all.size
    total_paid_dollar = '-'
    total_paid_credits = 0
    total_cost_dollar = '-'
    total_cost_credits = AiCall.where("ai_calls.data->>'status' = ?", 'succeeded').sum(:cost_credits)
    total_left_dollar = '-'
    total_left_credits = total_paid_credits - total_cost_credits

    today_newly_users = User.where("DATE(created_at) = ?", Date.today).count
    today_paid_users = '-'
    today_generated_users = User.joins(conversations: :ai_calls)
                                .where(ai_calls: { created_at: Time.current.beginning_of_day..Time.current.end_of_day })
                                .distinct
                                .count
    today_images = AiCall.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count
    today_paid_dollar = '-'
    today_paid_credits = '-'
    today_cost_dollar = '-'
    today_cost_credits = AiCall.succeeded_ai_calls
                           .where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
                           .sum(:cost_credits)

    freeium_total_credits = total_users * (ENV.fetch('FREEMIUM_CREDITS') { 0 }).to_i
    freeium_cost_credits = total_cost_credits
    freeium_left_credits = freeium_total_credits - freeium_cost_credits
    freeium_run_out_users = '-'
    # User.joins(:replicated_calls)
    #                          .where("replicated_calls.data->>'status' = ?", 'succeeded')
    #                          .group('users.id')
    #                          .having('COUNT(*) >= ?', 0)
    #                       .select("users.id, users.email, COUNT(*) as successful_call_count")

    user_top_paid_dollar = '-'
    user_top_paid_credits = '-'
    user_top_cost_dollar = '-'
    user_top_cost_credits = User.joins(conversations: :ai_calls)
                                .group("users.id")
                                .select("users.id, sum(cost_credits) as cost_credits")
                                .order('cost_credits desc')
                                .limit(1)
                                .first
                              &.cost_credits

    user_top_generated_images = User.joins(conversations: :ai_calls)
                                    .group("users.id")
                                    .select("users.id, users.email, COUNT(*) as call_count")
                                    .order("call_count desc")
                                    .limit(1)
                                    .first
                                  &.call_count
    render json: {
      total_users: total_users,
      total_paid_users: total_paid_users,
      total_generated_user: total_generated_user,
      total_images: total_images,
      total_paid_dollar: total_paid_dollar,
      total_paid_credits: total_paid_credits,
      total_cost_dollar: total_cost_dollar,
      total_cost_credits: total_cost_credits,
      total_left_dollar: total_left_dollar,
      total_left_credits: total_left_credits,
      today_newly_users: today_newly_users,
      today_paid_users: today_paid_users,
      today_generated_users: today_generated_users,
      today_images: today_images,
      today_paid_dollar: today_paid_dollar,
      today_paid_credits: today_paid_credits,
      today_cost_dollar: today_cost_dollar,
      today_cost_credits: today_cost_credits,
      freeium_total_credits: freeium_total_credits,
      freeium_cost_credits: freeium_cost_credits,
      freeium_left_credits: freeium_left_credits,
      freeium_run_out_users: freeium_run_out_users,
      user_top_paid_dollar: user_top_paid_dollar,
      user_top_paid_credits: user_top_paid_credits,
      user_top_cost_dollar: user_top_cost_dollar,
      user_top_cost_credits: user_top_cost_credits,
      user_top_generated_images: user_top_generated_images
    }.to_json
  end

  def ai_call_info
    params[:page] ||= 1
    params[:per] ||= 20

    ai_calls = AiCall
                 .order("created_at desc")
                 .page(params[:page].to_i)
                 .per(params[:per].to_i)

    result = ai_calls.map do |item|
      {
        input_media: (
          item.input_media.map do |media|
            url_for(media)
          end
        ),
        generated_media: (
          item.generated_media.map do |media|
            url_for(media)
          end
        ),
        prompt: item.prompt,
        status: item.status,
        input: item.input,
        data: item.data,
        created_at: item.created_at,
        cost_credits: item.cost_credits,
        system_prompt: item.system_prompt,
        business_type: item.business_type
      }
    end

    render json: {
      total: ai_calls.total_count,
      histories: result
    }
  end

  def error_log
    params[:page] ||= 1
    params[:per] ||= 20

    error_log = ErrorLog
                 .order("created_at desc")
                 .page(params[:page].to_i)
                 .per(params[:per].to_i)


    render json: {
      total: error_log.total_count,
      error_log: error_log.map do |log|
        {
          # id: log.id,
          type: log.error_type,
          message: log.message,
          controller_name: log.controller_name,
          action_name: log.action_name,
          email: log.user_email,
          created_at: log.created_at,
        }
      end
    }
  end
end