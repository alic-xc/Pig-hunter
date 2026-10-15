# Pig Hunter

A stylized 3D top-down endless hunting game built with Godot 4. The hunter rides a horse along an endless trail while pigs close in from the surrounding fields. Weapons auto-target nearby threats, and a dog companion contributes its own attacks.

## Web demo (investor build)

`web/index.html` is a self-contained, playable 3D demo built with Three.js. It's styled after the *Endless Rails* screenshots: a diagonal trail, a high orthographic camera, toon shading with ink outlines, and waves with upgrade picks.

- 6 guns: Six-Shooter, Scattergun, Lever Rifle, Saddle Gatling, Crossbow, Dynamite (5 levels each)
- 4 hounds: Beagle, Bulldog (stuns), Bloodhound (extra gold), Sheepdog (knockback)
- 7 hogs: Piglet herds, Wild Boar, Razorback, Mud Hog (ranged), Iron Hog (armored), Tusker, and The Boar King boss every 5 waves
- Upgrade cards between waves, gem rerolls, coin heals, dash-trample, synthesized sound and music, touch controls on phones

Run it locally by opening `web/index.html` in a browser, or serve it:

```sh
python3 -m http.server 5178 --directory web
```

## Godot prototype

- Orthographic, diagonal 3D camera inspired by the supplied *Endless Rails* screenshots
- Endless scrolling trail and field
- Left/right horse steering
- Automatic rifle targeting and visible shot tracers
- Dog companion with independent close-range attacks
- Runner, sprinter, and brute pig variants
- Wave escalation, health, score, coins, damage numbers, game over, and restart
- Entirely original primitive placeholder art; no source-game assets are included

## Run

Open the folder in Godot 4.7 or run:

```sh
godot --path .
```

Controls: `A`/`D` or left/right arrows to steer. Shooting and dog attacks are automatic. Press `R` or `Space` after game over to restart.

## Direction

The visual target is colorful, toy-like, readable at a distance, and non-graphic. The reference is used for composition and game-feel only; Pig Hunter will have its own characters, terrain, UI, effects, and progression identity.

