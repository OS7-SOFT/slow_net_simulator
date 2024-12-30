## 1.0.0

# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-12-30

### Added

- Initial release of the `slow_net_simulator` package.
- Introduced `SlowNetSimulator.configure` for setting network speed and failure probability.
- Added predefined network speeds: `GPRS_2G`, `EDGE_2G`, `HSPA_3G`, and `LTE_4G`.
- Enabled simulation of network requests using `SlowNetSimulator.simulate`.
- Provided an overlay button for runtime control of network speed and failure probability.
- Added support for Dio and any asynchronous HTTP client in the `simulate` function.
- Included example usage in README with dynamic failure probability adjustment.
