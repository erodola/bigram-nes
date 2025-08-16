from bigram import train, quantize_transition_matrix

data_fname = './data/human_names.txt'
export_asm_ff = '../ff1/asm/T_matrix.asm'
export_asm_dw_0_23 = '../dw/asm/T_matrix_0_23.asm'
export_asm_dw_24_26 = '../dw/asm/T_matrix_24_26.asm'
export_dev = '../dev/src/T_matrix.h'
export_vanilla = '../vanilla/src/T_matrix.h'


# Train the bigram model on the human names dataset

print("Training bigram model on human names dataset...", end='', flush=True)

T = train(data_fname)

print(" done.")


# Quantize the transition matrix to 8-bit integers

T_quantized = quantize_transition_matrix(T)
vocab_size = T_quantized.shape[0]


# Export the quantized transition matrix to a C header file.

print("")
print("Exporting quantized transition matrix...", flush=True)

c_matrix = f"#define VOCAB_SIZE {vocab_size} // number of states in the transition matrix\n\n"

c_matrix += f"const uint8_t T[VOCAB_SIZE][VOCAB_SIZE] = "
c_matrix += '{\n'

for i in range(vocab_size):

    c_matrix += '  {'

    for j in range(vocab_size):

        x = int(T_quantized[i][j])
        c_matrix += str(x)

        if j < vocab_size - 1:
            c_matrix += ','
        else:
            c_matrix += '}'
        
    if i < vocab_size - 1:
        c_matrix += ','

    c_matrix += '\n'

c_matrix += '};\n'

with open(export_dev, 'w') as f:
    f.write(c_matrix)

print(f"\t{export_dev}")

with open(export_vanilla, 'w') as f:
    f.write(c_matrix)

print(f"\t{export_vanilla}")

# Export the quantized transition matrix to a .asm file for the FF hack.

asm_matrix = '.export TransitionMatrix\n'
asm_matrix += '.segment "BANK_0E_T"\n\n'

asm_matrix += "; Transition matrix for bigram model\n"
asm_matrix += "TransitionMatrix:\n"

for i in range(vocab_size):
    asm_matrix += '  .byte '
    for j in range(vocab_size):
        asm_matrix += f'${int(T_quantized[i][j]):02x}'
        if j < vocab_size - 1:
            asm_matrix += ', '
    asm_matrix += '\n'

with open(export_asm_ff, 'w') as f:
    f.write(asm_matrix)

print(f"\t{export_asm_ff}")

# Export the quantized transition matrix to two .asm files for the DW hack.

asm_matrix = "; Transition matrix for bigram model (rows 0-23)\n"

for i in range(24):
    asm_matrix += '  .byte '
    for j in range(vocab_size):
        asm_matrix += f'${int(T_quantized[i][j]):02x}'
        if j < vocab_size - 1:
            asm_matrix += ', '
    asm_matrix += '\n'

with open(export_asm_dw_0_23, 'w') as f:
    f.write(asm_matrix)

print(f"\t{export_asm_dw_0_23}")

asm_matrix = "; Transition matrix for bigram model (rows 24-26)\n"

for i in range(24, vocab_size):
    asm_matrix += '  .byte '
    for j in range(vocab_size):
        asm_matrix += f'${int(T_quantized[i][j]):02x}'
        if j < vocab_size - 1:
            asm_matrix += ', '
    asm_matrix += '\n'

with open(export_asm_dw_24_26, 'w') as f:
    f.write(asm_matrix)

print(f"\t{export_asm_dw_24_26}")

print("done.")
