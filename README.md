# DeskDoodles

Doodle on a desk?

## Sprite Cropping

Place uncropped sprite PNGs in `tool/raw_sprites/` and run

```
dart run tool/crop_sprites.dart
```

The script trims transparent padding and writes cropped copies to
`assets/your_room/`. Use `--dry-run` to preview changes or `--src` / `--out`
to override the directories. Original files remain untouched.
