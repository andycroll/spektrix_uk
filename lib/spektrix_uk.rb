require 'json'

require 'cinebase'

require_relative './spektrix_uk/version'

require_relative './spektrix_uk/internal/http'
require_relative './spektrix_uk/internal/api'
require_relative './spektrix_uk/internal/venue'
require_relative './spektrix_uk/internal/title_sanitizer'

require_relative './spektrix_uk/internal/parser/instance'

require_relative './spektrix_uk/cinema'
require_relative './spektrix_uk/performance'

# spektrix_uk gem
module SpektrixUk
end
