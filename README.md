# bendoom

The whole of Doom, rewritten in [Bend 2](https://github.com/bendlang/bend): every episode of Doom and Doom II, every monster and weapon, menus, saves, the automap and the original demos playing in sync. It is built in stages.

<p align="center"><img src="docs/e1m1.png" width="640" alt="Freedoom's E1M1 from the player start, drawn by shot.bend"></p>

## Stages

| | Stage | State |
|---|---|---|
| 1 | WAD and maps: any IWAD's directory, every map lump, the palette, the automap as an image | done |
| 2 | Walls: BSP traversal, composite textures, light and colormaps, a window | done |
| 3 | Floors, ceilings, sky, sprites and masked textures | done |
| 4 | Player and world: movement, collision, doors, lifts, line and sector specials | |
| 5 | Every monster, with the original states and AI | |
| 6 | Weapons, items, ammo, HUD and status bar | |
| 7 | Menus, in-game automap, skills, intermission, finales, every episode and Doom II | |
| 8 | Sound, music, saves and `.lmp` demos, played back in sync | |

## Use

    bend doom.bend -o doom
    ./doom doom.wad E1M1

`doom` opens a 640x400 window at the map's first player start. The arrow keys or W and S walk and turn, A and D or comma and period strafe, Shift runs and Escape quits. Walls, floors, ceilings, the sky, masked textures and the things placed on the map at medium skill are drawn as Doom draws them; things stand still until stage 5, and there is no collision until stage 4.

    bend shot.bend -o shot
    ./shot doom.wad E1M1 e1m1.bmp

`shot` renders the same view from the player start into a 320x200 BMP.

    bend automap.bend -o automap
    ./automap doom.wad E1M1 e1m1.bmp

    bend wadinfo.bend -o wadinfo
    ./wadinfo doom2.wad

`automap` draws a map the way Doom's automap does with every line revealed: one-sided walls red, floor steps brown, ceiling steps yellow, the rest grey, things as green crosses and player starts white, in the WAD's own palette. `wadinfo` prints every map with the count and a hash of each of its lumps.

Any Doom-format IWAD works: Doom, Doom II, Final Doom, or [Freedoom](https://freedoom.github.io), which is free and what the tests use.

## Tests

`./test.sh` downloads Freedoom 0.13.0 (checked by SHA-256), reads all 68 maps of `freedoom1.wad` and `freedoom2.wad` and compares every field of every lump with `tests/wadinfo.py`, an independent reader in Python, then checks three automaps and three rendered views against their known images. `BEND=path/to/bend ./test.sh` picks the compiler.

## Layout

| File | What |
|---|---|
| `src/wad.bend` | the WAD header and directory, lumps read on demand at their offset |
| `src/level.bend` | a map's lumps as typed records |
| `src/tab.bend` | `Vec`, a shared, indexable table for data read once and looked up often |
| `src/bytes.bend` | little-endian words, lump names, signed 16-bit values |
| `src/fixed.bend`, `src/tables.bend` | Doom's 16.16 fixed point on `U32`, and its sine, tangent, arctangent and random tables |
| `src/gfx.bend`, `src/load.bend` | patches, `PNAMES`, `TEXTURE1`/`TEXTURE2`, composite textures built column by column as Doom builds them, flats and the sky |
| `src/world.bend` | a map in the form the renderer reads: fixed-point segs, sides and sectors with texture and flat offsets, and its things |
| `src/render.bend` | the BSP walk, clipping, wall columns, visplanes, spans and the sky, after `r_bsp.c`, `r_segs.c` and `r_plane.c` |
| `src/draw.bend` | sprites, masked mid textures and the fuzz effect sorted and clipped against drawsegs, after `r_things.c`; the palette lookup at the end of a frame |
| `src/mem.bend`, `src/rom.bend` | the two flat arrays a frame works in: `rom` holds colormaps, light tables, the palette, textures, flats and sprite patches for the level; `ram` holds clip arrays, visplanes, openings, drawsegs and vissprites |
| `src/sprite.bend` | map things filtered by skill, sprite frames and rotations installed as `R_InstallSpriteLump` does |
| `src/info.bend` | sprite names, states and mobj info from `info.c` |
| `src/screen.bend` | the 320x200 frame as a 512x512 Morton-ordered array, which maps onto a window image directly |
| `src/boot.bend`, `src/play.bend` | loading a map and its textures, the player start, input and movement |
| `src/automap.bend`, `src/bmp.bend`, `src/sys.bend` | the automap drawn into an array, BMP output, writing files |
| `tools/gen_tables.py` | generates `src/tables.bend` from id Software's `tables.c` and `m_random.c` |
| `tools/gen_info.py` | generates `src/info.bend` from id Software's `info.c`, `info.h`, `sounds.h` and `p_mobj.h` |

## Limits

- **Bend 2.0.36**, native build (`-o`). The programs run under `bend file.bend` too, but a whole WAD overflows the JS lane's stack.
- Map nodes must be in Doom's original format; ZDoom's extended nodes come later, with PWAD support.

The code is GPL-2.0, the license of Doom's source. The WADs are not included.
