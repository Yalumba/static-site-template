module Statique
  module Helpers
    def absolute_image_url(image)
      "#{request.scheme}://#{request.host}#{image_path(image)}"
    end
  end
end