# web-game template

Zero-build browser game starter: open index.html and it runs (Phaser 3
via CDN, plain game.js). Ships with a local headless self-check.

## Run the game

Serve the folder (any static server) or just open index.html.
Arrow keys move the basket. Catch 10 stars to win, miss 5 and it's over.

## Self-check (local headless Chromium — no cloud browser, ever)

    npm install                  # once: playwright dev dependency
    npx playwright install chromium
    node check.mjs . ./check-out

check.mjs serves the folder, drives headless Chromium through
check-flow.mjs (default export `async (page, shot)`), captures console
errors, page errors and failed requests, and writes check-out/report.json
plus a screenshot series (boot, flow steps, final). Exit 0 means no
captured problems — still look at every screenshot before calling it good.

## Adapt to your brief

1. Rewrite game.js for your game; keep `window.game` exposed.
2. Rewrite check-flow.mjs to script YOUR core flow: real inputs, real
   assertions, `await shot("name")` at each meaningful state.
3. Re-run the check after every change.
