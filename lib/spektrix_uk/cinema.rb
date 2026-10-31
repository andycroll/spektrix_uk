module SpektrixUk
  # An independent cinema that sells tickets through Spektrix
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the gem's id of the cinema, e.g. 'tyneside'

    # Constructor
    # @param [String, Symbol] id the cinema id, e.g. 'tyneside'
    # @return [SpektrixUk::Cinema]
    def initialize(id)
      @id = id.to_s
    end

    # Every supported cinema, held in the gem
    # @return [Array<SpektrixUk::Cinema>]
    # @example
    #   SpektrixUk::Cinema.all
    #   #=> [<SpektrixUk::Cinema>, <SpektrixUk::Cinema>, ...]
    def self.all
      SpektrixUk::Internal::Venue::ALL.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = SpektrixUk::Cinema.new('tyneside')
    #   cinema.adr
    #   #=> {
    #         street_address:   '10 Pilgrim Street',
    #         extended_address: nil,
    #         locality:         'Newcastle upon Tyne',
    #         region:           nil,
    #         postal_code:      'NE1 6QG',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      venue.address
    end

    # Brand of the cinema
    # @return [String] which will always be 'Independent'
    def brand
      'Independent'.freeze
    end

    # @return [Float] latitude of the cinema
    def latitude
      venue.latitude
    end

    # @return [Float] longitude of the cinema
    def longitude
      venue.longitude
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   SpektrixUk::Cinema.new('tyneside').name
    #   #=> 'Tyneside Cinema'
    def name
      venue.name
    end

    # The cinema's own website
    # @return [String]
    # @example
    #   SpektrixUk::Cinema.new('tyneside').url
    #   #=> 'https://tynesidecinema.co.uk'
    def url
      venue.url
    end

    private

    def venue
      SpektrixUk::Internal::Venue.find(id)
    end
  end
end
