# Pig Hunter — Art Pipeline (ChatGPT → Claude)

This guide is how every image for Pig Hunter gets made. **All images come from ChatGPT.** Claude never draws or downloads art. Claude reads your images and builds the 3D game from them.

```
You ask ChatGPT ──► ChatGPT makes the image ──► You check it (checklist)
      ▲                                                   │
      │                                                   ▼
Claude gives a fix-up prompt ◄── not right ── You save it in web/art/ and tell Claude
                                                          │
                                                       right ▼
                                     Claude builds the model, shows you, publishes
```

We go **one asset at a time**, in this order:

| Step | Asset | Files you'll make |
|---|---|---|
| 0 | Style anchor (do once) | `style-anchor.png` |
| 2 | Horse | `horse-sheet.png`, `horse-coat.png` |
| 3 | Dogs (4 breeds) | `dog-beagle-sheet.png`, `dog-bulldog-sheet.png`, `dog-bloodhound-sheet.png`, `dog-sheepdog-sheet.png` |
| 4 | Pigs (8 kinds) | `pig-piglet-sheet.png`, `pig-sow-sheet.png`, `pig-boar-sheet.png`, `pig-razorback-sheet.png`, `pig-mudhog-sheet.png`, `pig-ironhog-sheet.png`, `pig-tusker-sheet.png`, `pig-bertha-sheet.png`, `pig-skin.png` |
| 5 | Guns (6) | `gun-revolver.png`, `gun-shotgun.png`, `gun-rifle.png`, `gun-gatling.png`, `gun-crossbow.png`, `gun-dynamite.png` |
| 6 (optional) | Hunter | `hunter-sheet.png` |

Step 1 (gameplay) is already done.

---

## Ground rules for every image

1. **One ChatGPT conversation for the whole project.** Keep using the same chat so the style stays consistent. If you have to start a new chat, re-upload `style-anchor.png` first and say "match this style exactly".
2. **Ask for one image at a time.** Don't ask for several animals in one picture.
3. **Download the full-size PNG.** Use ChatGPT's download button. Screenshots lose detail.
4. **Name it exactly as listed** above and save it in `pig-hunter/web/art/`.
5. **Never mention another game, studio or artist** in a prompt (no "like Endless Rails", no "Pixar style"). That keeps the art yours and safe to show investors.
6. If ChatGPT adds text, labels, arrows or a busy background, use the fix-up prompts at the bottom.

### What makes a good reference sheet (check before saving)

- [ ] Plain white background, nothing else in the picture
- [ ] Exactly the views asked for (side, top, front), laid out left to right, with no overlap
- [ ] **Flat orthographic views**: the side view is perfectly side-on and the top view looks straight down, with no tilt or perspective
- [ ] All views show the **same animal at the same scale**
- [ ] Clear, solid colours with no heavy shading or dramatic lighting
- [ ] No text, labels, measurements, arrows or watermarks
- [ ] Matches the style anchor (same outline weight, same colour feel)

### What makes a good texture (check before saving)

- [ ] Square image
- [ ] **Seamless**: the left edge continues into the right, and the top into the bottom
- [ ] Flat and evenly lit, with no shadows, highlights or vignette
- [ ] Only the surface (fur or skin), with no animal shape, objects or text

---

## Step 0 — Style anchor (do this once, first)

This image sets the look for everything that follows.

**Prompt:**

> I'm making a 3D top-down hunting game set in sunny western countryside. I need a **style reference image** that I'll use to keep every future image consistent.
>
> Draw a small lineup on a plain white background: a chestnut horse with a western saddle, a beagle, and a pink pig, standing side by side and seen from the side.
>
> Style: stylized realism, like a high-quality mobile game. Believable animal anatomy and proportions, slightly chunky and friendly. Clean confident dark-brown outlines (not black). Warm, saturated earthy palette. Soft cel shading with 2–3 tones. No background scenery, no text, no shadows on the ground.

Save as `web/art/style-anchor.png`, then tell Claude: **"Style anchor is ready."**

Claude will check that the style suits low-poly 3D building and may ask for one adjustment before you continue.

---

## Step 2 — Horse

### 2a. Horse reference sheet

**Prompt:**

> Using the exact style of the reference image we made, create a **character reference sheet** of the hunter's horse, with no rider.
>
> Horse: a muscular chestnut quarter horse. Dark brown mane and tail, white blaze down the face, white socks on the back legs, dark hooves. Western saddle in dark leather with a saddle horn, a red-and-cream striped saddle blanket, bridle and reins.
>
> Show **three views** in a row on a plain white background, all the same scale:
> 1. **Side view** (facing right), standing
> 2. **Top-down view** looking straight down (head pointing right)
> 3. **Front view**
>
> Orthographic views, no perspective. Even flat lighting. No text, labels or arrows.

Save as `web/art/horse-sheet.png`.

### 2b. Horse coat texture

**Prompt:**

> Create a **seamless tileable texture** of short chestnut horse hair, seen close up, for a 3D game. Subtle hair direction, gentle colour variation, matching the chestnut of our horse. Square image, flat even lighting, no shadows, no highlights, no objects, no text.

Save as `web/art/horse-coat.png`.

Then tell Claude: **"Horse images are ready."**

**What Claude does next:** checks both images and builds a new horse in code from the sheet. The sheet sets the body shape, muscle groups, leg joints, mane, tail, saddle and tack. The texture is wrapped onto the coat, and the gallop animation is improved to match. You get a screenshot to approve before it's published.

---

## Step 3 — Dogs

Make **one sheet per breed**. Use this template and swap in each breed's description.

**Template prompt:**

> Using the exact style of our reference image, create a **character reference sheet** of a hunting dog: **[BREED DESCRIPTION]**. It wears a red leather collar.
>
> Show **three views** in a row on a plain white background, all the same scale: 1. side view (facing right), standing; 2. top-down view looking straight down (head pointing right); 3. front view. Orthographic, no perspective, even flat lighting, no text or labels.

| File | [BREED DESCRIPTION] |
|---|---|
| `dog-beagle-sheet.png` | a beagle: tan, white and black tricolour coat, long floppy ears, white-tipped tail held up, alert and quick |
| `dog-bulldog-sheet.png` | an American bulldog: stocky and wide-chested, short white coat with grey-brown patches, broad head, strong jaw |
| `dog-bloodhound-sheet.png` | a bloodhound: deep red-brown coat, very long droopy ears, loose wrinkled skin on the face, nose to the ground |
| `dog-sheepdog-sheet.png` | a border collie: black and white coat with a white chest and blaze, upright pointed ears, lean and athletic |

After each one, tell Claude: **"[Breed] is ready."** You can also make all four and say **"All dogs are ready."**

---

## Step 4 — Pigs

Same idea: one sheet per pig type. The **mother sow must look clearly different** from the others, since she's the only one that attacks.

**Template prompt:**

> Using the exact style of our reference image, create a **character reference sheet** of **[PIG DESCRIPTION]**.
>
> Show **three views** in a row on a plain white background, all the same scale: 1. side view (facing right), standing; 2. top-down view looking straight down (head pointing right); 3. front view. Orthographic, no perspective, even flat lighting, no text or labels. Friendly and non-gory.

| File | [PIG DESCRIPTION] |
|---|---|
| `pig-piglet-sheet.png` | a small pink piglet with big ears, a curly tail and a cute round body |
| `pig-sow-sheet.png` | a large protective mother sow: rose-pink with a few brown spots, heavy body, floppy ears, determined frowning eyebrows, a sturdy stance |
| `pig-boar-sheet.png` | a wild boar: brown bristly coat, darker spiky ridge along the back, small upward tusks, long snout |
| `pig-razorback-sheet.png` | a lean, fast razorback hog: grey-brown coat, tall sharp bristle ridge along the spine, long legs, narrow body |
| `pig-mudhog-sheet.png` | a chunky farm hog covered in splashes of dark mud, dirty brown-pink skin, happy expression |
| `pig-ironhog-sheet.png` | a pink hog wearing a dented metal farmer's helmet and a riveted metal plate strapped on its back, like improvised armour |
| `pig-tusker-sheet.png` | a huge, heavy dark-brown boar with thick curved tusks, a scarred snout and a shaggy dark mane |
| `pig-bertha-sheet.png` | "Big Bertha", an enormous queen mother sow: dusty rose-pink, a small golden crown with red jewels, a fierce protective expression, huge and round but still a believable pig |

**Pig skin texture** (shared by all pigs and tinted per type in code):

> Create a **seamless tileable texture** of pink pig skin close up for a 3D game: fine sparse light hairs, subtle mottling and pores, soft and clean. Square image, flat even lighting, no shadows, no highlights, no objects, no text.

Save as `web/art/pig-skin.png`.

---

## Step 5 — Guns

The hunter holds these, so a **side view only** is fine. Keep them believable, period-western firearms.

**Template prompt:**

> Using the exact style of our reference image, draw **[GUN DESCRIPTION]**, seen **exactly from the side** (barrel pointing right), centred on a plain white background. Orthographic, no perspective, even flat lighting, no hands, no text, no labels.

| File | [GUN DESCRIPTION] |
|---|---|
| `gun-revolver.png` | a classic 1870s single-action six-shot revolver: blued steel barrel and cylinder, brass trigger guard, walnut grip |
| `gun-shotgun.png` | a side-by-side double-barrel coach shotgun: two dark steel barrels, exposed hammers, walnut stock |
| `gun-rifle.png` | an 1870s lever-action rifle: long octagonal steel barrel, brass receiver, lever loop, walnut stock and fore-end |
| `gun-gatling.png` | a compact hand-cranked multi-barrel gatling gun sized to mount on a saddle: brass housing, six steel barrels, side crank |
| `gun-crossbow.png` | a wooden hunting crossbow: walnut stock, steel bow limbs, taut string, a loaded bolt with green fletching |
| `gun-dynamite.png` | a bundle of three red dynamite sticks tied with twine, with a lit fuse giving off a small spark |

---

## Step 6 (optional) — Hunter

> Using the exact style of our reference image, create a **character reference sheet** of the hunter: a rugged frontier hunter in a brown wide-brim cowboy hat, teal work shirt, brown leather vest, red neck bandana, blue jeans, dark boots, short beard and moustache. Three views in a row on a plain white background, same scale: side (facing right), top-down looking straight down, front. Orthographic, no perspective, even flat lighting, no text or labels.

---

## Fix-up prompts (when ChatGPT gets it wrong)

Paste one into the same chat, right after the image that went wrong.

| Problem | Say this |
|---|---|
| Added text or labels | "Same image, but remove every word, label, number and arrow." |
| Busy background or ground shadow | "Same image on a pure plain white background, with no ground shadow and no scenery." |
| Views are tilted or in perspective | "Redo it as strict orthographic views: the side view perfectly side-on, and the top view looking straight down from directly above." |
| Views are different sizes | "Redo it with all three views at exactly the same scale, evenly spaced in a single row." |
| Style drifted | "This doesn't match our reference image. Redo it with the same outline weight, colour palette and shading as the style reference." |
| Too cartoony | "Make the anatomy more realistic: correct leg joints, muscle shape and proportions, keeping the same art style." |
| Too realistic or gritty | "Make it friendlier and cleaner: simpler shapes, warmer colours, softer shading." |
| Texture shows a visible seam | "Make it truly seamless: the left edge must continue into the right edge, and the top into the bottom." |

If an image still isn't right after two fix-ups, save the best one anyway and tell Claude what bothers you. Claude can correct proportions and colours when building the model.

---

## What to tell Claude, and what you'll get back

| You say | Claude does |
|---|---|
| "Style anchor is ready." | Reviews it and confirms or asks for one tweak |
| "Horse images are ready." | Builds the horse, shows you a screenshot, and publishes once you approve |
| "[Breed] is ready." / "All dogs are ready." | Builds the dogs, shows you, publishes |
| "[Pig] is ready." / "All pigs are ready." | Builds the pigs, shows you, publishes |
| "Guns are ready." | Builds the guns into the hunter's hands, shows you, publishes |

Every finished step is committed to git. You then run `git push` to send it to GitHub.
