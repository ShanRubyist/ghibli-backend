class SaveToOssJob < ApplicationJob
  queue_as :default

  def perform(ai_call_id, type = :generated_media, args)
    media = args.fetch(:io)

    io = case media
         when String
           require 'open-uri'
           URI.open(media)
         when Tempfile
           media
         end

    AiCall.find_by(id: ai_call_id)
      .send(type.to_sym)
      .attach(io: io, filename: args.fetch(:filename), content_type: args.fetch(:content_type))
  end
end