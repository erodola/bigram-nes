#include "../lib/neslib.h"
#include "../lib/nesdoug.h" 
#include <stdint.h>

#define BLACK 0x0f
#define DK_GY 0x00
#define LT_GY 0x10
#define WHITE 0x30

#pragma bss-name(push, "ZEROPAGE")

unsigned char i, j;    // loop index, used in many places
uint8_t acc;           // accumulator for multinomial sampling -- guaranteed by T to be always <= 255
unsigned char attempts;

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

// RNG implementation (8-bit step)
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
		if (r < acc)
			return i;
	}

	return VOCAB_SIZE - 1; // fallback if r == 255
}

unsigned char new_name[] = { // zero terminated c string of at most 4 characters
	0x0, 0x0, 0x0, 0x0, 0x0
};

unsigned char itos(unsigned char i) {
	// convert index to character
	if (i == 0) {
		return '.';
	} else {
		return 'a' + i - 1;
	}
}

uint8_t c_idx; // the character index of the generated name

void generate_name(void){

	c_idx = 0;

	for (j = 0; j < 3; ++j) 
	{
		// try to generate a character different from '.'
		attempts = 0;
		do {
			c_idx = multinomial(T[c_idx]);
			attempts++;
		} while (c_idx == 0 && attempts < 255);

		// if still '.', force it to 'a'
		if (c_idx == 0)
			c_idx = 1;

		new_name[j] = itos(c_idx);
	}

	// generate the 4th character optionally

	c_idx = multinomial(T[c_idx]);

	if (c_idx == 0) {
		new_name[3] = 0x0;
		return;
	}
	
	new_name[3] = itos(c_idx);
	new_name[4] = 0x0;
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

			// write new name to screen at fixed position
			vram_adr(NTADR_A(2, 2));
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
