# Search field

A search field collects a query: a leading search glyph, a placeholder and a clear affordance that appears once there is something to clear. `DsSearchField` composes the standard text field, so it inherits the field family's fill, border, focus and disabled treatments and sits flush beside other form controls. Use it to filter a collection in place (a toolbar above a table, a picker with many options) or to start a lookup. The caller owns the query: pass a controller to read, seed or clear it from outside, and apply the filtering yourself in `onChanged`.

While the field is non-empty an inline clear button renders on the trailing edge; pressing it empties the field, reports an empty query through `onChanged` and fires `onClear`. For an asynchronous lookup, set `pending` while results load and a small spinner replaces the clear affordance, so the field itself signals work in flight. A null `onChanged` disables the field and removes it from the focus order, the system's controlled convention.

## Guidelines

**Do**

- Filter as the user types and keep the full list one clear away.
- Say what is searched in the hint, such as `Search accounts`.
- Set `pending` while an asynchronous lookup runs so the field shows progress.
- Pair the field with a visible result count so progress is obvious.
- Pass a controller when a toolbar action or filter reset must clear the query.

**Don't**

- Don't add a separate search button; the field submits with the keyboard's search action.
- Don't hide the clear affordance behind a menu; clearing must be one tap.
- Don't use a search field for navigation; it queries the current collection.
- Don't debounce so long that results feel detached from typing.

## Example

```dart
DsSearchField(
  controller: queryController,
  hintText: 'Search accounts',
  pending: isLoading,
  onChanged: (query) => applyFilter(query),
  onClear: resetFilter,
);
```

## See also

- [Text fields](text-fields.md)
- [Filter controls](filter-controls.md)
