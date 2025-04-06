module Bot
  class Replicate < AIModel
    def initialize
    end

    def image_api(prompt, options = {})
      aspect_ratio = options.fetch(:aspect_ratio, '1:1')
      model_name = options.fetch(:model_name)
      model = ::Replicate.client.retrieve_model(model_name)

      version = model.latest_version
      # webhook_url = "https://" + ENV.fetch("HOST") + "/replicate/webhook"
      prediction = version.predict(prompt: prompt,
                                   #aspect_ratio: aspect_ratio, disable_safety_checker: true,
                                   image: options.fetch(:image),
                                   "model": "dev",
                                   "go_fast": true,
                                   "lora_scale": 1,
                                   "megapixels": "1",
                                   "num_outputs": 1,
                                   "aspect_ratio": "1:1",
                                   "output_format": "webp",
                                   "guidance_scale": 10,
                                   "output_quality": 80,
                                   "prompt_strength": 0.77,
                                   "extra_lora_scale": 1,
                                   "num_inference_steps": 38
      # go_fast: true,
      # guidance_scale: 10,
      # prompt_strength: 0.77,
      # num_inference_steps: 38,
      # afety_tolerance: 5
                                   )

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