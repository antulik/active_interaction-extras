# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

- Updated minimum required version to v4.0.2

## [1.0.1] - 2021-05-13

- Fix `run_in_transaction` in ruby 3 [#8](https://github.com/antulik/active_interaction-extras/pull/8)

## [1.0.0] - 2021-05-12

- Requires active_interaction v4
- New filters: `anything` and `uuid`
- New filter extensions
    - object: support for multiple classes 
    - hash: disable auto strip when no keys are listed
- New extension: 
    - filter alias
- Changed `transaction` extension
    - It requires new transaction by default
    - Include order is important now
- Removed `active_interaction-active_job` gem dependency
- Added changelog
