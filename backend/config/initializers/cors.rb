Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:5173").split(",").map(&:strip)
    resource "*",
             headers: :any,
             methods: %i[get post patch put delete options head]
  end
end
