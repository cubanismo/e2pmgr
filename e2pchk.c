#include <stdio.h>
#include <inttypes.h>

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

		chksum += w;
	}

	chksum ^= 0xFFFF;

	if (fread(&w, sizeof(w), 1, f) != 1) {
		fprintf(stderr, "ERROR: Failed to read EEPROM file\n");
		return 1;
	}

	if (w != chksum) {
		fprintf(stderr, "ERROR: Checksum mismatch\n");
		fprintf(stderr, "  Calculated: 0x%04x File: 0x%04x\n",
			chksum, w);
		return 2;
	}

	fclose(f);

	printf("SUCCESS: Checksum is valid\n");

	return 0;
}
