Testing the PWA Web Share Target locally

1. Build the web app then serve on localhost (service workers work on localhost)

```bash
./scripts/serve_web.sh
```

2. Open a Chromium-based mobile browser (or desktop Chrome) and navigate to:

```
http://localhost:8080
```

3. To test the Web Share Target:
- On Android Chrome, open any page with text, tap Share → choose your installed PWA (or use the browser's share to installed PWA).
- Alternatively, use the `curl` command to POST directly to the share-target endpoint:

```bash
curl -X POST -d "text=Hello%20from%20curl" http://localhost:8080/share-target
```

This will cause the service worker to open the app at `/?shared=Hello%20from%20curl` which the app reads and processes automatically.

Notes
- Service workers require HTTPS except for `localhost`, so serving on `localhost` is sufficient for local testing.
- iOS Safari does not support Web Share Target.
