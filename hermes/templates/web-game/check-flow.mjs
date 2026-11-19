// Sample self-check flow for Star Catcher.
// Default export: async (page, shot) => {} — shot(name) saves a PNG.
export default async (page, shot) => {
  const scene = () => page.evaluate(() => {
    const s = window.game.scene.keys.main;
    return { x: s.basket.x, caught: s.caught, overlay: s.overlay.text };
  });

  await page.waitForFunction(
    () => window.game && window.game.scene.keys.main && window.game.scene.keys.main.basket,
    null, { timeout: 15000 });
  await shot('title');

  // Real input: basket must move left.
  const x0 = (await scene()).x;
  await page.keyboard.down('ArrowLeft');
  await page.waitForTimeout(400);
  await page.keyboard.up('ArrowLeft');
  const x1 = (await scene()).x;
  if (!(x1 < x0)) throw new Error(`basket did not move left (${x0} -> ${x1})`);
  await shot('gameplay');

  // Real catch: spawn a star directly above the basket, wait for the overlap.
  await page.evaluate(() => {
    const s = window.game.scene.keys.main;
    s.spawnStar(s.basket.x);
  });
  await page.waitForFunction(() => window.game.scene.keys.main.caught >= 1,
    null, { timeout: 8000 });

  // Force the win overlay through the public endGame API.
  await page.evaluate(() => window.game.scene.keys.main.endGame(true));
  await page.waitForTimeout(200);
  const txt = (await scene()).overlay;
  if (txt !== 'You win') throw new Error(`win overlay wrong: "${txt}"`);
  await shot('win');
};
