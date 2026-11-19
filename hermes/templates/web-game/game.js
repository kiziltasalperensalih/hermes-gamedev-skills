// Star Catcher — sample game for the web-game template.
// Brief: arrow keys move a basket; catch 10 falling stars to win,
// miss 5 and it's game over. 480x640. Exposes window.game.
const W = 480, H = 640;

class MainScene extends Phaser.Scene {
  constructor() {
    super('main');
    this.caught = 0;
    this.missed = 0;
    this.over = false;
  }

  create() {
    const g = this.make.graphics({ add: false });
    g.fillStyle(0xffd75e); g.fillCircle(12, 12, 12);
    g.generateTexture('star', 24, 24); g.clear();
    g.fillStyle(0x8b5a2b); g.fillRect(0, 0, 80, 26);
    g.generateTexture('basket', 80, 26); g.destroy();

    this.basket = this.physics.add.sprite(W / 2, H - 40, 'basket');
    this.basket.setCollideWorldBounds(true);
    this.basket.body.setAllowGravity(false);

    this.stars = this.physics.add.group({ allowGravity: false });
    this.cursors = this.input.keyboard.createCursorKeys();
    this.physics.add.overlap(this.basket, this.stars, (_b, s) => this.catchStar(s));
    this.spawnTimer = this.time.addEvent({ delay: 700, loop: true, callback: () => this.spawnStar() });

    this.hud = this.add.text(12, 10, 'Caught: 0 / 10   Missed: 0 / 5',
      { fontSize: '18px', color: '#ffffff' });
    this.overlay = this.add.text(W / 2, H / 2, '', { fontSize: '48px', color: '#ffffff' })
      .setOrigin(0.5).setVisible(false);
  }

  spawnStar(x) {
    if (this.over) return;
    const sx = (x === undefined) ? Phaser.Math.Between(20, W - 20) : x;
    const s = this.stars.create(sx, -20, 'star');
    s.body.setAllowGravity(false);
    s.setVelocityY(Phaser.Math.Between(180, 300));
  }

  catchStar(s) {
    if (this.over) return;
    s.destroy();
    this.caught++;
    this.refreshHud();
    if (this.caught >= 10) this.endGame(true);
  }

  update() {
    if (this.over) { this.basket.setVelocityX(0); return; }
    const v = this.cursors.left.isDown ? -260 : this.cursors.right.isDown ? 260 : 0;
    this.basket.setVelocityX(v);
    for (const s of this.stars.getChildren().slice()) {
      if (s.y > H + 30) {
        s.destroy();
        this.missed++;
        this.refreshHud();
        if (this.missed >= 5) { this.endGame(false); break; }
      }
    }
  }

  refreshHud() {
    this.hud.setText(`Caught: ${this.caught} / 10   Missed: ${this.missed} / 5`);
  }

  endGame(won) {
    if (this.over) return;
    this.over = true;
    this.spawnTimer.remove();
    this.stars.clear(true, true);
    this.overlay.setText(won ? 'You win' : 'Game over').setVisible(true);
  }
}

window.game = new Phaser.Game({
  type: Phaser.AUTO,
  width: W,
  height: H,
  backgroundColor: '#101828',
  physics: { default: 'arcade', arcade: { gravity: { y: 0 } } },
  scene: MainScene,
});
