# Changelog

## v1.4.1 - 2024-04-17

### What's Changed

#### 🐛 Bug Fixes

- fix: use `fn.keach` to iterate over signal values @b0o (#31)

## v1.4.0 - 2024-04-15

### What's Changed

#### 🚀 Features

- feat: add `debounce` and `start_with` operators @mobily (#27)

## v1.3.0 - 2024-04-14

### What's Changed

#### 🚀 Features

- feat: add support for `max_lines` prop for paragraph component @mobily (#25)

#### 🐛 Bug Fixes

- fix: schedule setting buffer modifiable @b0o (#18)
- fix: ensure that the `signal_values` provided are resolved correctly when using `combine_latest` @mobily (#24)
- fix: paragraph width calculation @b0o (#21)

## v1.2.0 - 2024-04-01

### What's Changed

#### 🚀 Features

- feat: extmark-based placeholder for text inputs @willothy (#7)
- Feat validator combinators @willothy (#12)

#### 🚩 Other Changes

- chore: Add `deploy-docs` workflow @mobily (#14)

## v1.1.0 - 2024-03-31

### What's Changed

#### 🚀 Features

- feat: add `Renderer:get_component_by_direction` @willothy (#8)
- feat: ✨ Allows modifying the appearance and behavior of the floating window @mobily (#4)

#### 🐛 Bug Fixes

- fix: remove right padding from paragraph and descendants @willothy (#11)
- Tree fixes for nested node handling (scroll and id generation) @willothy (#6)
