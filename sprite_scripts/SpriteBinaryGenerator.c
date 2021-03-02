/* SpriteParser.c - Parses the t files from matlab into an MIF file format
 */

#include <stdio.h>
#include <stdlib.h>

#define INPUT_FILE "sprite_bytes/right.txt"			// Input filename
#define OUTPUT_FILE "right.ram"		// Name of file to output to

int main()
{
	char line[21];
	FILE *in = fopen(INPUT_FILE, "r");
	FILE *out = fopen(OUTPUT_FILE, "w");

	if(!in)
	{
		printf("Unable to open input file!");
		return -1;
	}
                    
	// Get a line, convert it to an integer, and compare it to the palette values.
	while(fgets(line, 20, in) != NULL)
	{
		int val;
		val = (int) strtol(line, NULL, 16);
		val = ((val & 0xF80000) >> 8) + ((val & 0x00FC00) >> 5) + ((val & 0x0000F8) >> 3);
		val = ((val & 0xFF) << 8) + ((val & 0xFF00) >> 8);
		fwrite(&val, 2, 1, out);
	}

	fclose(out);
	fclose(in);
	return 0;
}
