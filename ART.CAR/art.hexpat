
struct DataHeader
{
    u8 type;   // 20 texture?
    u8 length;
    u8 unknown[2];
    u32 zero; //?
    u32 offset;
    u8 data[48];
    u32 width; //maybe only for textures?
    u32 height;
};

struct ArtData {
    char magic[4];
    u32 filesize;
    u32 dataHeaderCount;
    u32 dataHeaderLength;
    DataHeader dataHeaders[dataHeaderCount];
};

ArtData header @0x00;

