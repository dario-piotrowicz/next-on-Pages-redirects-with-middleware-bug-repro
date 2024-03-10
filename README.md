# Next-on-Pages middleware redirect bug reproduction

This issue shows a bug in the current `@cloudflare/next-on-pages` (as of `1.10.0`) where redirections due to the
default trailing slash removal are not properly applied when a middleware is present.

Meaning that if you build the application and navigate to `/api/hello/` you get the expected route's result (a `Hello World` message)
but the response is a `200` and there is no redirection to `/api/hello`.

## Reproduction steps

Install the dependencies with:
```sh
$ npm i
```

### Manual Test

Preview the application using next-on-pages via:
```sh
$ npm run preview
```

navigate to `/api/hello/` with your network tab open and notice
how no redirection nor `308` response is ever returned

(while running the application with `next dev` presents such redirection)

### Automated Test

then `test.sh` builds the project, starts it using both `npm run dev` and `next-on-pages`/`wrangler`, runs test cases and kills the server.

Run `./test.sh` to run a test case against both `npm run dev` and `next-on-pages`/`wrangler`.

You should see the following result:
```

####################################################################################


starting npm run dev…
appending output to nohup.out
..
## npm run dev
 * With slash: 308
 * Without slash:    200

starting wrangler…
appending output to nohup.out
....................................................................................................

## wrangler
 * With slash: 200 ❗️
 * Without slash:    200

```

showcasing that navigating to a route with a slash does result in a `200` response when using next-on-pages (while when using the standard next dev server you do get the expected `308`).

> [!NOTE]
> Disclaimer:
> The `.test.sh` script was shamelessly copied and tweaked from
> https://github.com/gabrielf/wrangler-api-route-trailing-slash
