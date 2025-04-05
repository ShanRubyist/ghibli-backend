class SaveToOssJob < ApplicationJob
  queue_as :default

  def perform(ai_call, type = :generated_media, args)
    ai_call
      .send(type.to_sym)
      .attach(io: args.fetch(:io), filename: args.fetch(:filename), content_type: args.fetch(:content_type))
  end
end