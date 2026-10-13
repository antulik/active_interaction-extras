# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.0.0] - 2026-10-13

- Add the `ar_relation` filter for `ActiveRecord::Relation` inputs without forcing relation loading when checking defaults
- Extend the `uuid` filter to accept UUID versions 5 and 7.
- Add Rails-style `NestedAttributes` for single and collection inputs, including `allow_destroy` and `reject_if`. Nested attributes now require explicit `permit:` rules.
- Extend `StrongParams` to support object filters and custom permit lists for scalar, hash, object, array, and nested-attribute inputs.
- Add `FormFor` to delegate form identity and routing to a model input, and `ModelNames` to derive route keys for namespaced forms.
- Add an `AfterInitialize` callback hook plus `InitializeWith` and `AppendInputs` for post-initialization defaults that do not overwrite explicitly supplied inputs; allow `initialize_with` blocks to return `nil` and ensure defaults run after model-field initialization.
- Add `InstanceRunnable` with one-shot instance execution and `save`/`save!` methods for form-style usage.
- Add `IncludeErrors` to merge model validation errors into interaction errors and halt when the model is invalid.
- Extend `ModelFields` with `assign_model_fields`, `assign_model_changes`, `save_model!`, and `save_model_changes!`; improve change detection for new records and plain objects, and preserve custom filter blocks.
- Add `NamedCallbacks` for before, after, and around filter, validation, and execution callbacks.
- Extend transaction helpers to allow disabling transactions and add `force_explicit_transactions!` and `list_missing_transaction_definition` for enforcing and auditing transaction choices.
- Add ActiveJob inline execution and the `Current` context for the running job; avoid redundant job dispatch during GoodJob batch completion.
- Add GoodJob batch and concurrency support, including current batch/event context, and `AddToBatch` for joining the current batch.
- Add `AllRunner` to run an interaction for every record in its object scope, synchronously or through GoodJob bulk enqueueing.
- Add `FileBlobs` helpers for working with ActiveStorage blobs, attachments, and signed IDs in form objects.
- Refactor extensions for Zeitwerk autoloading; require Ruby 3.0+, ActiveModel and ActiveSupport 7.1+, and Zeitwerk 2+. Update CI to cover Ruby 3.2 through 4.0.

## [1.1.0] - 2023-03-08

- Add support for active_interaction v5
- Fix `model_fields` helper

## [1.0.4] - 2022-06-08

- Improve halt's robustness (https://github.com/antulik/active_interaction-extras/pull/13)

## [1.0.3] - 2021-07-11

- Loosen the gem requirements

## [1.0.2] - 2021-07-07

- Requires active_interaction v4.0.2 or higher
- Fixed `run_in_transaction!` to rollback when interaction finished with errors

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
