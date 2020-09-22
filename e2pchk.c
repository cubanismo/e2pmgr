#include <stdio.h>
#include <inttypes.h>

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define SWAP_WORD(w) (w) = (((w) << 8) | ((w) >> 8))
#else
#define SWAP_WORD(w) (void)(w)
#endif

int main(int argc, char *argv[])
{
	FILE *f;
	int i;
	uint16_t w, chksum = 0;

	if (argc < 2 || !(f = fopen(argv[1], "rb"))) {
		printf("usage: e2pchk <file.e2p>");
		return 255;
	}

	for (i = 0; i < 63; i++) {
		if (fread(&w, sizeof(w), 1, f) != 1) {
			fprintf(stderr, "ERROR: Failed to read EEPROM file\n");
			return 1;
		}

		SWAP_WORD(w);

		chksum += w;
	}

	chksum ^= 0xFFFF;

	if (fread(&w, sizeof(w), 1, f) != 1) {
		fprintf(stderr, "ERROR: Failed to read EEPROM file\n");
		return 1;
	}

	SWAP_WORD(w);

	if (w != chksum) {
		fprintf(stderr, "ERROR: Checksum mismatch\n");
		fprintf(stderr, "  Calculated: 0x%04" PRIx16
			" File: 0x%04" PRIx16 "\n", chksum, w);
		return 2;
	}

	fclose(f);

	printf("SUCCESS: Checksums match: 0x%04" PRIx16 "\n", chksum);

	return 0;
}
