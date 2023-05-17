# RFM - Level information

The files found in `Worlds\*.RFM` are maps, where:

- seek/skip `0x170` from start (not sure what this is yet)
- read a `WORD`, this is the width (seemingly always 128)
- read a `WORD`, this is the height (seemingly always 128)
- read 128x128 `BYTE`s of tiles

That array of 128x128 bytes indicates the _tile_ of that position in the map, emphasis on tile, not texture.

For example, a tile can be something simple and static like a sea tile `1`, or it could be something with logic like tile `201` which is a large enemy office that when blown up, has a bunch of little army people running out of it.

Or like tile `136`, which is a flowerbed texture as a base, along with another texture on top of 4 flowers.

For a better idea of how things link up, here's an exerpt of a few tiles in the game:

| Tile ID | Texture ID | Purpose |
| ------- | ---------- | ------- |
| 0   | 0   | Light sand |
| 1   | 2   | Light sea |
| 52  | 73  | Road vertical |
| 53  | 82  | Road corner top left |
| 54  | 76  | Road T-junction down |
| 55  | 83  | Road corner top right |
| 57  | 90  | Player bunker |
| 72  | 79  | Road horizontal |
| 93  | 80  | Road corner bottom left |
| 94  | 75  | Road T-junction up |
| 95  | 81  | Road corner bottom right |
