# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - 2026-11-03

### Changed
- Uses cinebase 5.9: performances take the raw `title:`, so audience labels become variants, and series prefixes such as `Met Opera:` become the performance's `event`.

## [1.0.1] - 2026-11-02

### Changed
- Requests and London times use cinebase 5.8's `Cinebase::Http` and `Cinebase::London`.
- Requests retry dropped connections twice.
- HTTP errors read "HTTP error 500 from system.spektrix.com" instead of "Spektrix HTTP error 500".

## [1.0.0] - 2026-11-01

### Added
- `SpektrixUk::Cinema.all` and `SpektrixUk::Cinema.new(id)` for Tyneside Cinema, Broadway, Showroom Cinema, Hyde Park Picture House and HOME, with addresses and coordinates held in the gem.
- `SpektrixUk::Performance.at(id, from:, to:)`, from each venue's public Spektrix API, with films only, booking links, variants, dimensions, film years and festivals, following cinebase 5.6.
- Fixtures trimmed from live responses, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
