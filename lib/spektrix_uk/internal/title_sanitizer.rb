module SpektrixUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # Square-bracketed notes, e.g. '[35mm]', '[+ Filmmaker Q&A]' or
      # Tyneside's programme year '[2026]'
      NOTES = /\s*\[[^\]]*\]/

      # Strands and seasons named before a colon, e.g. 'Classics: Dracula'
      STRANDS = [
        'Baby Kino', 'BHM\d+', 'Classics', 'Cult', 'DocNights', 'Dog Friendly', 'Early Doors(?: - \w+)?',
        'Family Time', 'FF[FS]\d+(?: x [^:]+)?', 'Film Studies', 'FT', 'Healthy Holidays',
        'Into Film Festival', 'Japanese Film Club presents', 'My Movie', 'PBPB', 'Perspectives',
        'Philosophy', 'Popcorn & Prosecco', 'Presents', 'Preview', 'Queer East \d+',
        'Queer Up Duck! Festival', 'Reclaim the Frame presents', 'Spotlight',
        'TK', 'Toddler Kino', 'UK Jewish Film Festival', 'VHS Screening', 'WTF'
      ].freeze

      # Extras after a '+', e.g. 'The Holiday + Popcorn & Prosecco'
      EXTRAS = [
        'Event', 'Family Yoga', 'Intro(?:duction)?', 'Live Score.*', 'Mince Pie & Prosecco',
        'Popcorn & Prosecco', 'Shorts?'
      ].freeze

      # Versions after a dash, e.g. 'Elf - Pay What You Feel'
      VERSIONS = [
        '\d+(?:st|nd|rd|th) Anniversary', '4K Restoration', 'Parent & Baby', 'Pay What You Feel',
        'Presented by .*', 'Quiet Coach.*', 'Santa Extravaganza', 'Sing Along'
      ].freeze

      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [SpektrixUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          NOTES,
          /\s*\((?:U|PG|12A?|15|18|R18|CTBA|TBC)\)/,                  # certificate
          /\s*\((?:Preview|NEIFF|[^)]*Festival)\)/i,                  # preview or festival
          /\AChristmas \d+\s*[-:]\s*/,                                # season
          /\A(?!NT Live|Royal )[^\/]{1,30}\/\s+/,                     # strand, e.g. 'Cinema Social/ '
          /\A(?:#{STRANDS.join('|')}):\s*/,                           # strand, e.g. 'Classics: '
          /\A(?:FFS\d+|See It First –|Family Film Club -|Family Supper Club -)\s+/, # strand
          /\A(?:Festive Afternoon Tea|Supper Club) \+\s*/,            # food before the film
          /\s+\+\s+(?:#{EXTRAS.join('|')})\z/i,                       # extras after the film
          /\s*\+[^+]*\bQ&A\b.*\z/i,                                   # Q&A, e.g. '+ Q&A with the director'
          /\s+[-–]\s+(?:#{VERSIONS.join('|')})\z/i,                   # version
          /:\s*\d+(?:st|nd|rd|th) Anniversary\z/i,                    # anniversary
          /\s+Family Event\z/i,                                       # family event
          /\s*\(\d+(?:st|nd|rd|th) Anniversary [^)]*\)/i,             # anniversary restoration
          /\s*\(4K Restoration\)/i                                    # restoration
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\A(?:EOS|Exhibition on Screen):\s*(.*)/i                             => 'Exhibition on Screen: ',
          /\A(.*) - Met Opera \d+\/\d+\z/                                        => 'Met Opera: ',
          /\A(?:NT Live|NTL|National Theatre Live)[:\/]\s*(.*)/                  => 'National Theatre Live: ',
          /\A(?:RBO|(?:The )?Royal (?:Ballet|Opera)(?: and Opera)?)[:\/]\s*(.*)/ => 'Royal Ballet and Opera: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
