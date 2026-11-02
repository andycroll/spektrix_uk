# frozen_string_literal: true

require "time"

module SpektrixUk
  # @api private
  module Internal
    module Parser
      # Parses a Spektrix instance of a film into performance attributes
      class Instance
        # Variants a title names, at any venue
        TITLE_VARIANTS = {
          /\bQ&A\b/i => "q&a",
          /\b35mm\b/i => "35mm",
          /\A(?:Baby Kino|Baby & Carer\/)|Parent & Baby/i => "baby",
          /\b(?:Toddler Kino|Family Time|Family Film)\b|\A(?:TK|FT):/ => "kids",
          /\bRelaxed Screening\b/i => "relaxed"
        }.freeze

        THREE_D = /\b3D\b/
        YEAR = /\A\d{4}\z/

        # @param [Hash] instance one Spektrix instance
        # @param [Hash] event the event the instance belongs to
        # @param [SpektrixUk::Internal::Venue] venue the venue that sells it
        def initialize(instance, event:, venue:)
          @instance = instance
          @event = event
          @venue = venue
        end

        # @return [Hash] options for SpektrixUk::Performance.new
        def to_hash
          {
            booking_url: format(@venue.booking_url, instance: @instance.fetch("id")[/\A\d+/]),
            dimension: three_d? ? "3d" : "2d",
            festival: Cinebase::Festival.from_title(title, year: starting_at.year),
            film_name: TitleSanitizer.new(title).sanitized,
            film_year: film_year,
            starting_at: starting_at,
            variant: variant
          }
        end

        private

        def film_year
          year = @event[@venue.year].to_s.strip
          if year.match?(YEAR)
            year.to_i
          else
            Cinebase::TitleSanitizer.film_year(title.gsub(TitleSanitizer::NOTES, ""))
          end
        end

        # startUtc is UTC though it carries no zone
        def starting_at
          @starting_at ||=
            if @instance["startUtc"]
              Time.iso8601(@instance["startUtc"].delete_suffix("Z") + "Z")
            else
              local = Time.iso8601("#{@instance.fetch('start')}Z")
              Cinebase::London.utc(local)
            end
        end

        def three_d?
          @instance[@venue.three_d] == true || title.match?(THREE_D)
        end

        def title
          @title ||= @event.fetch("name").strip
        end

        def variant
          attributes = [[@venue.event_variants, @event], [@venue.instance_variants, @instance]]
          variants = attributes.flat_map do |map, record|
            map.filter_map { |attribute, values| values[record[attribute]] }
          end
          variants += TITLE_VARIANTS.filter_map { |pattern, name| name if title.match?(pattern) }
          variants.uniq
        end
      end
    end
  end
end
