# Custom Global Entry Icons — Design

**Date:** 2026-07-18
**Branch:** `custom-global-entry-icons`
**Status:** Designed autonomously (user asleep); pending user review post-implementation

## Background & motivation

The redesigned globals ("💪 FLEX") screen renders every entry as a grid tile: a rounded
colored square containing an SF Symbol, with the title below. Built-in entries get their
color and symbol from `+[FLEXGlobalsViewController colorForRow:]` /
`+symbolNameForRow:`, stored on `FLEXGlobalsEntry.iconColor` / `.symbolName` and consumed
by `FLEXGlobalsGridCell`.

Custom entries registered through `FLEXManager+Extensibility`
(`registerGlobalEntryWithName:objectFutureBlock:` and friends) never set those
properties, so their tiles fall back to a hash-derived palette color
(`FLEXGridColorForName`) with an **empty square** — no symbol. Developers should be able
to pick both.

## Goals

- Let developers specify an SF Symbol name and a tile color when registering a custom
  global entry, for all three registration flavors (object future, view controller
  future, row action).
- Preserve existing behavior for the current API: nil symbol → empty square, nil color →
  hash-derived palette color.
- Zero behavior change for built-in entries.

## Non-goals

- No custom `UIImage` support — the grid is SF Symbol-based; symbols keep tiles
  consistent (weight/point-size config lives in `FLEXGlobalsGridItemView`).
- No fallback glyph (e.g. first letter) for symbol-less entries — separate idea, not
  requested.
- No reordering/sectioning of custom entries.

## Alternatives considered

1. **`symbolName:iconColor:` variants of the three register methods** *(chosen)* — matches
   the codebase's explicit Obj-C API style; existing methods become conveniences that
   pass nil/nil. Additive, source- and binary-compatible.
2. **Return the created `FLEXGlobalsEntry` from the register methods** so callers mutate
   it directly. Technically source-compatible, but exposes a mutable internal model
   object as public API surface and makes future changes harder. Rejected.
3. **Options/config parameter object.** Overkill for two attributes; no precedent in this
   codebase. Rejected.

## API

In `FLEXManager (Extensibility)`:

```objc
- (void)registerGlobalEntryWithName:(NSString *)entryName
                         symbolName:(nullable NSString *)symbolName
                          iconColor:(nullable UIColor *)iconColor
                  objectFutureBlock:(id (^)(void))objectFutureBlock;

- (void)registerGlobalEntryWithName:(NSString *)entryName
                         symbolName:(nullable NSString *)symbolName
                          iconColor:(nullable UIColor *)iconColor
          viewControllerFutureBlock:(UIViewController * (^)(void))viewControllerFutureBlock;

- (void)registerGlobalEntryWithName:(NSString *)entryName
                         symbolName:(nullable NSString *)symbolName
                          iconColor:(nullable UIColor *)iconColor
                             action:(FLEXGlobalsEntryRowAction)rowSelectedAction;
```

- `symbolName` is an SF Symbol name (`[UIImage systemImageNamed:]`); an unrecognized name
  resolves to nil image, i.e. degrades to today's empty square.
- `iconColor` is the tile background; the symbol itself always renders white (grid-wide
  styling, unchanged).
- The three existing methods delegate to the new ones with `nil`/`nil` — one code path.
- Parameter names mirror the `FLEXGlobalsEntry` property names. Stale doc comments on
  those properties ("Nil for custom entries") are updated.

No rendering changes: `FLEXGlobalsGridCell` already applies
`entry.iconColor ?: FLEXGridColorForName(name)` and `entry.symbolName`.

## Testing & verification

- Unit tests (FLEXTests, pure logic): registering via each new method stores
  symbol/color on the entry in `FLEXManager.userGlobalEntries`; nil passthrough leaves
  them nil; legacy methods still produce nil-icon entries. Tests clean up via
  `clearGlobalEntries`.
- Visual: FLEXample registers a demo custom entry using the new API; build, launch in
  simulator, screenshot the globals screen to confirm tile color + symbol render.
