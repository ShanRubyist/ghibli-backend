module Bot
  class Replicate < AIModel
    def initialize
    end

    def image_api(prompt, options = {})
      model_name = options.fetch(:model_name)
      model = ::Replicate.client.retrieve_model(model_name)

      version = model.latest_version
      # webhook_url = "https://" + ENV.fetch("HOST") + "/replicate/webhook"
      prediction = version.predict(options)

      prediction
    end

    private

    def query_image_task_api(prediction)
      data = prediction.refetch

      if prediction.succeeded?
        return {
          status: 'success',
          image: prediction.output,
          data: data
        }
      elsif prediction.failed? || prediction.canceled?
        fail 'generate image failed or canceled:' + data.fetch('error')
      else
        return {
          status: data['status'],
          image: prediction&.output,
          data: data
        }
      end
    end
  end
end