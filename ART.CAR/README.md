# ART.CAR - Textures and sprites

`Art\art.car` contains all the sprites/textures in the game.

An ImHex pattern is available as [art.hexpat](./art.hexpat),
as well as a Lazarus visualization app in [the lazarus_viewer folder](./lazarus_viewer/).

### File header

* `DWORD`, magic (always `CCBA`)
* `DWORD`, `file length`
* `DWORD`, `data header count`
* `DWORD`, `data header length`

### Data headers

* for `data header count` do:
  * `BYTE`, type
  * `BYTE`, length
  * `WORD`, unknown
  * `DWORD`, seemingly always zero
  * `DWORD`, `file offset`
  * `BYTE[48]`, unknown
  * `DWORD`, `width`
  * `DWORD`, `height`

### Image data  

* for each data header
  * seek to `header.file offset`
  * `BYTE[width*height]` for image array
  * use indexed-palette to convert each byte to 24-bit colour value
