class SaveToOssJob < ApplicationJob
  queue_as :default

  def perform(ai_call, type = :generated_media, args)
    media = args.fetch(:io)

    io = case media
         when media.start_with?('http')
           require 'uri'
           URI.open(media)
         else
           media
         end

    ai_call
      .send(type.to_sym)
      .attach(io: io, filename: args.fetch(:filename), content_type: args.fetch(:content_type))
  end
end