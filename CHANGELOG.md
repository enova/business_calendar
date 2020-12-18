# business_calendar changes by version

2.0.0
---------

- Remove UK weekend holidays, replace with the actual observed holiday dates [#26]

1.1.0
---------

- Cache parsed responses from API endpoints for TTL (Time to Live) duration.
- Increase default TTL duration from 5 minutes to 1 day.
  Holidays are not expected to frequently change.
- Allow disabling cache clearing by setting `ttl` to `false`.
- Set hard limit to size of memoized holidays cache,
  since large quantities of user supplied dates could consume excessive memory / cause DoS.

1.0.0
---------

- Initial version 1 release
- Add option to fetch holidays from a URL [#19]
- Install new dependencies while preserving support for ruby 1.8.7 [#20] and [#22]
- Add option to treat weekends as business days [#21]
