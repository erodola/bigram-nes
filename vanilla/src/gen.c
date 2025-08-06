#include "../lib/neslib.h"
#include "../lib/nesdoug.h" 
#include <stdint.h>

#define BLACK 0x0f
#define DK_GY 0x00
#define LT_GY 0x10
#define WHITE 0x30
// there's some oddities in the palette code, black must be 0x0f, white must be 0x30

#pragma bss-name(push, "ZEROPAGE")

// GLOBAL VARIABLES
// all variables should be global for speed
// zeropage global is even faster

unsigned char i;            // loop index, used in many places
uint16_t acc;               // accumulator for multinomial sampling
unsigned char x, y;         // coordinates for placement

const unsigned char palette[]={
BLACK, DK_GY, LT_GY, WHITE,
0,0,0,0,
0,0,0,0,
0,0,0,0
};

#include "T_matrix.h"


// --- 8-bit RNG implementation ---

uint8_t rng_seed = 0x5A;
uint8_t rng_counter = 0; // Add a counter for more entropy

// NESdev RNG implementation (8-bit step)
// uses linear feedback shift register (LFSR) for better randomness
uint8_t nes_rand8() {
    // Use a combination of LFSR and counter for better randomness
    rng_counter++;
    
    // XorShift algorithm - much better period
    rng_seed ^= rng_seed << 1;
    rng_seed ^= rng_seed >> 1;
    rng_seed ^= rng_seed << 2;
    rng_seed ^= rng_counter; // Mix in counter
    
    if (rng_seed == 0) rng_seed = 1; // Prevent stuck state
    
    return rng_seed;
}

// Multinomial sampling that only uses sums and comparisons (no log or exp).
// Assumes that the input is a probability distribution of raw counts (integers).
int multinomial(uint8_t* probs) {

	uint8_t r = nes_rand8();

	acc = 0;

	for (i = 0; i < VOCAB_SIZE; ++i) {
		acc += probs[i];
		if (r < acc) {
			return i;
		}
	}

	return VOCAB_SIZE - 1; // in case of rounding errors, return the last index
}

unsigned char new_name[] = { // zero terminated c string of at most 8 characters
	0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
};

unsigned char itos(unsigned char i) {
	// convert index to character
	if (i == 0) {
		return '.';
	} else {
		return 'a' + i - 1;
	}
}

unsigned char stoi(unsigned char c) {
	// convert character to index
	if (c == '.') {
		return 0;
	} else {
		return c - 'a' + 1; // 'a' is 1, 'b' is 2, ..., 'z' is 26
	}
}

void generate_name(void){
	// generate a name using the transition matrix T
	// 3-8 character constraint
	// unelegant code for efficiency

	unsigned char attempts;

    // Generate first character (max 255 attempts)
    attempts = 0;
    do {
        new_name[0] = itos(multinomial(T[0]));
        attempts++;
    } while (new_name[0] == '.' && attempts < 255);
    
    // If still '.', force it to 'a' to prevent infinite loop
    if (new_name[0] == '.') {
        new_name[0] = 'a';
    }

    // Generate second character (max 255 attempts)
    attempts = 0;
    do {
        new_name[1] = itos(multinomial(T[stoi(new_name[0])]));
        attempts++;
    } while (new_name[1] == '.' && attempts < 255);
    
    // If still '.', force it to 'a'
    if (new_name[1] == '.') {
        new_name[1] = 'a';
    }

    // Generate third character (max 255 attempts)
    attempts = 0;
    do {
        new_name[2] = itos(multinomial(T[stoi(new_name[1])]));
        attempts++;
    } while (new_name[2] == '.' && attempts < 255);
    
    // If still '.', force it to 'a'
    if (new_name[2] == '.') {
        new_name[2] = 'a';
    }

	// now we have at least 3 characters, generate the rest

	new_name[3] = itos(multinomial(T[stoi(new_name[2])]));

	if (new_name[3] == '.') {
		new_name[3] = 0x0;
		return;
	}

	new_name[4] = itos(multinomial(T[stoi(new_name[3])]));

	if (new_name[4] == '.') {
		new_name[4] = 0x0;
		return;
	}

	new_name[5] = itos(multinomial(T[stoi(new_name[4])]));

	if (new_name[5] == '.') {
		new_name[5] = 0x0;
		return;
	}

	new_name[6] = itos(multinomial(T[stoi(new_name[5])]));

	if (new_name[6] == '.') {
		new_name[6] = 0x0;
		return;
	}

	new_name[7] = itos(multinomial(T[stoi(new_name[6])]));

	if (new_name[7] == '.')
		new_name[7] = 0x0;

	// the name is truncated to 8 characters

	new_name[8] = 0x0;
}

void main(void) {

	// screen off
	ppu_off(); 

	//	load the BG palette
	pal_bg(palette);
	
	// turn on screen
	ppu_on_all(); 

	while (1){

		// wait for the next frame. NMI handler will poll the pads.
        ppu_wait_nmi();

		// wait for A button press
		if (pad_trigger(0) & PAD_A) {

			// screen off for VRAM writes
			ppu_off();
			
			// clear entire screen (32x30 tiles)
			vram_adr(NTADR_A(0, 0));
			vram_fill(' ', 32*30);
			
			// generate new name
			generate_name();
			
			// generate random position for the name
			x = nes_rand8() % 25;      // 0-24 (leave room for 8-char name: 32-8=24)
			y = 1 + nes_rand8() % 28;  // 1-28 (for some reason FCEUX hides the first/last row)

			// write new name to screen at random position
			vram_adr(NTADR_A(x, y));
			i = 0;
			while(new_name[i]){
				vram_put(new_name[i]);
				++i;
			}
			
			// turn screen back on
			ppu_on_all();
		}
	}
}
