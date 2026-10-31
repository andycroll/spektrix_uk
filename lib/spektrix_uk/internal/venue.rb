# frozen_string_literal: true

module SpektrixUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    Venue = Data.define(
      :id, :name, :client, :url, :booking_url, :adr, :latitude, :longitude,
      :film, :three_d, :year, :event_variants, :instance_variants
    )

    # A cinema selling through Spektrix. Each Spektrix account names its
    # attributes differently, so each venue says how to read them.
    #
    # @!attribute [r] id
    #   @return [String] the gem's own stable id, e.g. 'tyneside'
    # @!attribute [r] client
    #   @return [String] the Spektrix account, e.g. 'tynesidecinema'
    # @!attribute [r] booking_url
    #   @return [String] format string taking the instance number
    # @!attribute [r] film
    #   @return [Proc] whether an event is a film
    # @!attribute [r] three_d
    #   @return [String, nil] instance attribute marking 3D
    # @!attribute [r] year
    #   @return [String, nil] event attribute holding the film's year
    # @!attribute [r] event_variants
    #   @return [Hash] event attribute => { value => variant }
    # @!attribute [r] instance_variants
    #   @return [Hash] instance attribute => { value => variant }
    class Venue
      # Tickets, passes and courses that some venues file alongside films
      NOT_FILMS = /\bPass\z|\bBundle\b|\bLecture\b|Gift Voucher|Membership/i

      COUNTRY = "United Kingdom"

      ALL = [
        new(
          id: "broadway",
          name: "Broadway",
          client: "broadwaynottingham",
          url: "https://www.broadway.org.uk",
          booking_url: "https://www.broadway.org.uk/book/%<instance>s",
          adr: { street_address: "14-18 Broad Street", locality: "Nottingham", postal_code: "NG1 3AL" },
          latitude: 52.954306,
          longitude: -1.143663,
          film: ->(event) { event["attribute_Film"] == true || event["attribute_EventCinema"] == true },
          three_d: nil,
          year: "attribute_Year",
          event_variants: { "attribute_EventCinema" => { true => "arts" } },
          instance_variants: {
            "attribute_AD" => { true => "audio_described" },
            "attribute_Captioned" => { true => "subtitled" },
            "attribute_DementiaFriendly" => { true => "relaxed" },
            "attribute_FamilyMatinee" => { true => "kids" },
            "attribute_ParentAndBaby" => { true => "baby" },
            "attribute_SilverScreen" => { true => "senior" }
          }
        ),
        new(
          id: "home",
          name: "HOME",
          client: "home",
          url: "https://homemcr.org",
          booking_url: "https://tickets.homemcr.org/home/website/ChooseSeats.aspx?EventInstanceId=%<instance>s",
          adr: { street_address: "2 Tony Wilson Place", locality: "Manchester", postal_code: "M15 4FN" },
          latitude: 53.473626,
          longitude: -2.246606,
          film: ->(event) { event["attribute_ShowType"] == "Film" },
          three_d: nil,
          year: nil,
          event_variants: { "attribute_EventCategory" => { "Stage on Screen" => "arts" } },
          instance_variants: {
            "attribute_AdditionalEvent" => { "+ Q&A" => "q&a" },
            "attribute_AudioDescription" => { "AD" => "audio_described" },
            "attribute_CaptionSubtitled" => { "CAP" => "subtitled" },
            "attribute_ParentAndBaby" => { "Baby Friendly" => "baby" },
            "attribute_Relaxed" => { "Relaxed" => "relaxed" }
          }
        ),
        # The Leeds Heritage Theatres account also sells Leeds Grand Theatre
        # and City Varieties, which host some of the cinema's own screenings
        new(
          id: "hpph",
          name: "Hyde Park Picture House",
          client: "leedsheritagetheatres",
          url: "https://hpph.co.uk",
          booking_url: "https://tickets.hpph.co.uk/leedsheritagetheatres/website/ChooseSeats.aspx?EventInstanceId=%<instance>s",
          adr: { street_address: "73 Brudenell Road", locality: "Leeds", postal_code: "LS6 1JD" },
          latitude: 53.812058,
          longitude: -1.569421,
          film: lambda { |event|
            event["attribute_LiveOrFilm"] == "Film" && event["attribute_Website"] == "HPPH" &&
              ["Hyde Park Picture House", ""].include?(event["attribute_Venue"])
          },
          three_d: nil,
          year: "attribute_YearOfProduction",
          event_variants: {
            "attribute_AlternativeContent" => { true => "arts" },
            "attribute_AudioDescription" => { true => "audio_described" }
          },
          instance_variants: {
            "attribute_Analogue" => { "35mm" => "35mm" },
            "attribute_AudioDescribed" => { true => "audio_described" },
            "attribute_AutismFriendlyScreening" => { true => "relaxed" },
            "attribute_Captioned" => { true => "subtitled" },
            "attribute_CinemaSpecialEvent" => { "Q&A" => "q&a" },
            "attribute_DementiaFriendly" => { true => "relaxed" },
            "attribute_RelaxedPerformance" => { true => "relaxed" },
            "attribute_Strand" => { "Bring Your Own Baby" => "baby" },
            "attribute_ToddlerFriendlyScreening" => { true => "kids" }
          }
        ),
        new(
          id: "showroom",
          name: "Showroom Cinema",
          client: "showroomworkstation",
          url: "https://showroomcinema.org.uk",
          booking_url: "https://tickets.showroomcinema.org.uk/showroomworkstation/website/ChooseSeats.aspx?EventInstanceId=%<instance>s",
          adr: { street_address: "15 Paternoster Row", locality: "Sheffield", postal_code: "S1 2BX" },
          latitude: 53.377263,
          longitude: -1.46532,
          film: ->(event) { event["attribute_ShowroomNonFilmEvent"] != true },
          three_d: nil,
          year: nil,
          event_variants: {
            "attribute_Genre1Dropdown" => { "Alternative Content" => "arts", "Theatre" => "arts" },
            "attribute_Genre2Dropdown" => { "Alternative Content" => "arts" },
            "attribute_Genre3Dropdown" => { "Alternative Content" => "arts" }
          },
          instance_variants: {
            "attribute_AccessAudioDescribed" => { true => "audio_described" },
            "attribute_AccessDementiaFriendly" => { true => "relaxed" },
            "attribute_AccessRelaxed" => { true => "relaxed" },
            "attribute_AccessSubtitled" => { true => "subtitled" },
            "attribute_Strand" => { "Baby Kino" => "baby", "Family Time" => "kids", "Relaxed Screenings" => "relaxed" }
          }
        ),
        new(
          id: "tyneside",
          name: "Tyneside Cinema",
          client: "tynesidecinema",
          url: "https://tynesidecinema.co.uk",
          booking_url: "https://tynesidecinema.co.uk/book-online/%<instance>s",
          adr: { street_address: "10 Pilgrim Street", locality: "Newcastle upon Tyne", postal_code: "NE1 6QG" },
          latitude: 54.973903,
          longitude: -1.612254,
          film: ->(event) { event["attribute_Medium"] != "Non-Film" },
          three_d: "attribute_3DScreening",
          year: nil,
          event_variants: {
            "attribute_AudioDescription" => { true => "audio_described" },
            "attribute_Genre1" => { "Concert Film/Event Cinema" => "arts" }
          },
          instance_variants: {
            "attribute_35mmScreening" => { true => "35mm" },
            "attribute_DementiaFriendly" => { true => "relaxed" },
            "attribute_FamilyFilmClub" => { true => "kids" },
            "attribute_LiveSatelliteScreening" => { true => "arts" },
            "attribute_QAndAScreening" => { true => "q&a" },
            "attribute_RelaxedScreening" => { true => "relaxed" },
            "attribute_SilverScreen" => { true => "senior" },
            "attribute_SubtitledForHardOfHearing" => { true => "subtitled" },
            "attribute_TynesideBabyClub" => { true => "baby" }
          }
        )
      ].to_h { |venue| [venue.id, venue] }.freeze

      # @param [String] id e.g. 'tyneside'
      # @return [SpektrixUk::Internal::Venue]
      # @raise [KeyError] for an unknown id
      def self.find(id)
        ALL.fetch(id.to_s)
      end

      # @param [Hash] event a Spektrix event
      # @return [Boolean]
      def film?(event)
        film.call(event) && !event["name"].to_s.match?(NOT_FILMS)
      end

      # @return [Hash] address in microformats adr naming
      def address
        {
          street_address:   adr[:street_address],
          extended_address: nil,
          locality:         adr[:locality],
          region:           nil,
          postal_code:      adr[:postal_code],
          country_name:     COUNTRY
        }
      end
    end
  end
end
