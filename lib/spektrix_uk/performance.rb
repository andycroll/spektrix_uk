module SpektrixUk
  # A single screening of a film at a Spektrix cinema
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL for the screening
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year the film was made
    #   @option options [Time] :starting_at listed start time of the performance

    # Spektrix lists some films a month ahead at midnight, before the times
    # are set
    PLACEHOLDER_TIME = 'T00:00:00'.freeze

    # Films within an inclusive range of showing dates, from two requests for
    # any range: the venue's events and their instances.
    # @param [String] cinema_id id of the cinema, e.g. 'tyneside'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<SpektrixUk::Performance>]
    # @raise [KeyError] for an unknown cinema
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      venue = SpektrixUk::Internal::Venue.find(cinema.id)
      api = SpektrixUk::Internal::Api.new(venue.client)
      films = api.events(from, to + 1).select { |event| venue.film?(event) }.to_h { |event| [event.fetch('id'), event] }
      performances = screenings(api.instances(from, to + 1), films, from..to).map do |instance|
        parsed = SpektrixUk::Internal::Parser::Instance.new(instance, event: films.fetch(instance.dig('event', 'id')), venue: venue)
        new(parsed.to_hash.merge(cinema_id: cinema.id, cinema_name: cinema.name))
      end
      performances.sort_by(&:starting_at)
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (arts, audio_described, kids, subtitled ...)
    #   @return <Array[String]>

    # private

    # Instances that go ahead, of films, at a set time, on a London date in
    # the range
    def self.screenings(instances, films, dates)
      instances.select do |instance|
        start = instance.fetch('start')
        !instance['cancelled'] &&
          films.key?(instance.dig('event', 'id')) &&
          !start.end_with?(PLACEHOLDER_TIME) &&
          dates.cover?(Date.iso8601(start[0, 10]))
      end
    end
    private_class_method :screenings
  end
end
