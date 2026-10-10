# bendoom

The whole of Doom, rewritten in [Bend 2](https://github.com/bendlang/bend): every episode of Doom and Doom II, every monster and weapon, menus, saves, the automap and the original demos playing in sync. It is built in stages.

<p align="center"><img src="docs/e1m1.png" width="640" alt="Freedoom's E1M1 from the player start, drawn by shot.bend"></p>

## Stages

| | Stage | State |
|---|---|---|
| 1 | WAD and maps: any IWAD's directory, every map lump, the palette, the automap as an image | done |
| 2 | Walls: BSP traversal, composite textures, light and colormaps, a window | done |
| 3 | Floors, ceilings, sky, sprites and masked textures | done |
| 4 | Player and world: movement, collision, doors, lifts, line and sector specials | done |
| 5 | Every monster, with the original states and AI | done |
| 6 | Weapons, items, ammo, HUD and status bar | |
| 7 | Menus, in-game automap, skills, intermission, finales, every episode and Doom II | |
| 8 | Sound, music, saves and `.lmp` demos, played back in sync | |

## Use

    bend doom.bend -o doom
    ./doom doom.wad E1M1

`doom` opens a 640x400 window at the map's first player start and runs the game at Doom's 35 tics a second. The arrow keys or W and S walk and turn, A and D or comma and period strafe, Shift runs, Space or E uses, 1 to 7 pick a weapon and Escape quits.

The simulation is a port of id's: movement with momentum, friction, view bob and step-ups; collision against walls, things and the blockmap; doors, locked doors, lifts, floors, ceilings, crushers, stairs, donuts and light effects; walk, use and shoot line specials, switches and their timed return, teleports, animated flats and textures, scrolling walls, damaging and secret sectors; item pickups; and the exit, which loads the next map, or a death, which restarts the current one. Monsters see, hear, chase and attack as id's do: sight through the REJECT table and the BSP, sound flooding through sectors, melee, hitscan and missile attacks, homing revenant rockets, the arch-vile's resurrections and flame, pain elementals and lost souls, the boss deaths that open E1M8 and MAP07, and the Icon of Sin's cube spawner. Weapons do not fire until stage 6. Until stage 7, finishing an episode's last map (E?M8, MAP30) goes on to the next episode's first map.

    bend shot.bend -o shot
    ./shot doom.wad E1M1 e1m1.bmp

`shot` renders the same view from the player start into a 320x200 BMP.

    bend walk.bend -o walk
    ./walk doom.wad E1M1 out.bmp 200 1 at 600 712 180 2 128

`walk` plays a script without a window and saves the last frame. Each pair is a number of tics and the keys held through them as a bit mask: 1 forward, 2 back, 4 and 8 turn left and right, 16 and 32 strafe left and right, 64 run, 128 use, and 512, 1024 and so on up to 32768 pick weapons 1 to 7. `at X Y ANGLE` places the player. It prints the player's position, floor height, whether the level was exited, and the player's health.

    bend demo.bend -o demo
    ./demo doom.wad E1M1 run.lmp

`demo` plays a vanilla `.lmp` demo's tic commands without a window and prints one line per tic: the level time, the random index, the player's position, angle and health, the number of mobjs and a hash of every mobj's position, angle, state, tics, health and flags. The same line printed by a reference engine shows where the two part.

    bend automap.bend -o automap
    ./automap doom.wad E1M1 e1m1.bmp

    bend wadinfo.bend -o wadinfo
    ./wadinfo doom2.wad

`automap` draws a map the way Doom's automap does with every line revealed: one-sided walls red, floor steps brown, ceiling steps yellow, the rest grey, things as green crosses and player starts white, in the WAD's own palette. `wadinfo` prints every map with the count and a hash of each of its lumps.

Any Doom-format IWAD works: Doom, Doom II, Final Doom, or [Freedoom](https://freedoom.github.io), which is free and what the tests use.

## Tests

`./test.sh` downloads Freedoom 0.13.0 (checked by SHA-256), reads all 68 maps of `freedoom1.wad` and `freedoom2.wad` and compares every field of every lump with `tests/wadinfo.py`, an independent reader in Python, then checks three automaps and three rendered views against their known images, plays three short walks through E1M1: riding a lift down, opening a door and pressing the exit switch, and plays six demos across Doom and Doom II maps, built by `tests/mklmp.py`, whose traces must match the ones Chocolate Doom prints for the same demos, tic by tic, monsters included. `BEND=path/to/bend ./test.sh` picks the compiler.

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
| `src/state.bend` | the simulation's records and their accessors: lines, the move state, the level, the world with its mobjs, sectors, sides and the player |
| `src/sim.bend` | thinker lists, mobj ids, `P_Random`, and the helpers the rest builds on |
| `src/geo.bend` | `p_maputl.c`: point sides, line openings, sector and blockmap links, blockmap iteration and path traversal |
| `src/game.bend` | the game proper, one module because Doom's parts call each other: `p_mobj.c` spawning and state changes, `p_map.c` and `p_maputl.c` moves, slides, sight and aiming, hitscans and radius damage, `p_inter.c` damage and death, `p_enemy.c` monster AI and every action function, every line and sector special of `p_spec.c` and its kin, `p_user.c` and `P_Ticker` |
| `src/items.bend` | `P_TouchSpecialThing`: health, armor, ammo, weapons, keys and powers |
| `src/setup.bend` | `p_setup.c`: the level's lines, blockmap, sector boxes, animations and switches, and its thinkers at the start |
| `src/boot.bend`, `src/play.bend` | loading a map and its textures, the input to tic commands, the 35 Hz loop and level changes |
| `src/automap.bend`, `src/bmp.bend`, `src/sys.bend` | the automap drawn into an array, BMP output, writing files |
| `tools/gen_tables.py` | generates `src/tables.bend` from id Software's `tables.c` and `m_random.c` |
| `tools/gen_state.py` | generates `src/state.bend` |
| `tools/gen_tabs.py` | generates the walk-over and use tables of `src/game.bend` from the special numbers in `p_spec.c` and `p_switch.c` |
| `tools/gen_info.py` | generates `src/info.bend` from id Software's `info.c`, `info.h`, `sounds.h` and `p_mobj.h` |

## Limits

- **Bend 2.0.36**, native build (`-o`). The programs run under `bend file.bend` too, but a whole WAD overflows the JS lane's stack.
- Map nodes must be in Doom's original format; ZDoom's extended nodes come later, with PWAD support.

The code is GPL-2.0, the license of Doom's source. The WADs are not included.
