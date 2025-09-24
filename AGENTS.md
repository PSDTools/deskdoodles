# AI Agents

## Do

- Use available MCP tools instead of shell commands (e.g. use the Dart SDK MCP and GitKraken MCP servers).
- Use Riverpod for state management instead of Provider.
- Prefer hooks over StatefulWidget for better readability and maintainability.
- Use Freezed for data classes to avoid manual implementation of `==` and `hashCode.
- Use Material for all styling. No hard coding.
- Prefer smaller, reusable components.
- Minimize diff size unless otherwise requested.
- Always analyze the code before declaring it finished.

## Don’t

- Stop yapping and give me the code unless I ask for an explanation.
- Never hard code colors.

## Commands

Codegen: `dart run build_runner build`
Build: `flutter build <platform>`

## Safety and permissions

Ask first:
- Package installation
- Deleting files
- Running build

## Project structure

- See `lib/src/app/router.dart` for our routes
- Features go under `lib/src/features`.
  - Each feature has its own folder with `data`, `domain`, `application`, and `presentation` layers.
  - `data` layer (repositories): API calls, local storage.
  - `domain` layer (models, entities): data classes.
  - `application` layer (services): state management (providers), business logic.
  - `presentation` layer (pages): screens, other supporting widgets.

## Checklist

- Formatted
- Linted
- Run custom_lint
