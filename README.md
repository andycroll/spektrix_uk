# SpektrixUk

A simple gem to pull cinemas and performances from UK independent cinemas that sell tickets through [Spektrix](https://www.spektrix.com) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'spektrix_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spektrix_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing strands,
certificates, notes in square brackets, extras such as food or a Q&A, and
standardizing event cinema names.

No token or setup is needed. Each venue has its own Spektrix account, its
client, and the public Spektrix API v3 at
`https://system.spektrix.com/<client>/api/v3` lists its events and their
instances. Each account names its attributes differently, so the gem holds a
small configuration for each venue.

| id         | Cinema                  | Client                  |
|------------|-------------------------|-------------------------|
| `broadway` | Broadway, Nottingham    | `broadwaynottingham`    |
| `home`     | HOME, Manchester        | `home`                  |
| `hpph`     | Hyde Park Picture House | `leedsheritagetheatres` |
| `showroom` | Showroom Cinema         | `showroomworkstation`   |
| `tyneside` | Tyneside Cinema         | `tynesidecinema`        |

The ids belong to the gem and never change.

### Cinema

Cinemas, addresses and coordinates are held in the gem, so they make no
requests. Every cinema's brand is `'Independent'`.

``` ruby
SpektrixUk::Cinema.all
#=> [<SpektrixUk::Cinema ...>, <SpektrixUk::Cinema ...>, ...]

cinema = SpektrixUk::Cinema.new('tyneside')
#=> <SpektrixUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '10 Pilgrim Street',
  extended_address: nil,
  locality:         'Newcastle upon Tyne',
  region:           nil,
  postal_code:      'NE1 6QG',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Independent'

cinema.name
#=> 'Tyneside Cinema'

cinema.id
#=> 'tyneside'

cinema.latitude
#=> 54.973903

cinema.url
#=> 'https://tynesidecinema.co.uk'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. Any range takes two
requests: the events with an instance in the range, and the instances. The API
sets no limit on the range. The Leeds Heritage Theatres account answers slowly,
in about half a minute for a year.

``` ruby
SpektrixUk::Performance.at('tyneside', from: Date.today, to: Date.today + 2)
#=> [<SpektrixUk::Performance ...>, <SpektrixUk::Performance ...>, ...]

performance = SpektrixUk::Performance.at('tyneside').first
#=> <SpektrixUk::Performance ...>

performance.film_name
#=> 'The Grinch'

performance.film_year
#=> 2018 # from the venue's year attribute, or the title

performance.dimension
#=> '2d'

performance.variant
#=> ['audio_described', 'relaxed', 'subtitled']

performance.starting_at
#=> 2026-12-20 10:30:00 UTC

performance.booking_url
#=> 'https://tynesidecinema.co.uk/book-online/1808202'

performance.cinema_name
#=> 'Tyneside Cinema'

performance.cinema_id
#=> 'tyneside'
```

Only films are listed, including event cinema and screenings with a Q&A. Each
venue marks films in its own way:

| id         | Films are events where                                              |
|------------|---------------------------------------------------------------------|
| `broadway` | `Film` or `EventCinema` is true                                     |
| `home`     | `ShowType` is `Film`                                                |
| `hpph`     | `LiveOrFilm` is `Film`, `Website` is `HPPH` and `Venue` is the Picture House or blank |
| `showroom` | `ShowroomNonFilmEvent` is not true                                  |
| `tyneside` | `Medium` is not `Non-Film`                                          |

Passes, bundles and lectures are left out by name. Cancelled instances are left
out. Instances at midnight are left out, as Hyde Park Picture House lists films
at midnight on the last day of the month before their times are set. Instances
not on sale are kept: most have started or are not yet on sale.

Booking links go to each venue's own booking page:

| id         | Booking link                                                                    |
|------------|---------------------------------------------------------------------------------|
| `broadway` | `https://www.broadway.org.uk/book/<instance>`                                   |
| `home`     | `https://tickets.homemcr.org/home/website/ChooseSeats.aspx?EventInstanceId=<instance>` |
| `hpph`     | `https://tickets.hpph.co.uk/leedsheritagetheatres/website/ChooseSeats.aspx?EventInstanceId=<instance>` |
| `showroom` | `https://tickets.showroomcinema.org.uk/showroomworkstation/website/ChooseSeats.aspx?EventInstanceId=<instance>` |
| `tyneside` | `https://tynesidecinema.co.uk/book-online/<instance>`                           |

The instance is the number that starts a Spektrix instance id. Showroom and Hyde
Park Picture House open these pages in a frame on their own sites.

Variants are `35mm`, `arts`, `audio_described`, `baby`, `kids`, `q&a`,
`relaxed`, `senior` and `subtitled`, from each venue's event and instance
attributes and from titles. `subtitled` means captions or subtitles for
people who are deaf or hard of hearing, not a foreign language film's
subtitles.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live Spektrix API
```

Fixtures in `test/fixtures` are API responses captured from each venue's
account and trimmed to a few events. `test/support/api_shapes.rb` describes the
fields and attributes the gem reads. The unit suite checks the fixtures against
it and the live suite checks real responses, held only in memory. When an
account changes, update the shape first, then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
