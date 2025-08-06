from bigram import train, quantize_transition_matrix

data_fname = '../data/human_names.txt'
export_asm = '../ff1/asm/T_matrix.asm'
export_dev = '../dev/src/T_matrix.h'
export_vanilla = '../vanilla/src/T_matrix.h'


# Train the bigram model on the human names dataset

print("Training bigram model on human names dataset...", end='', flush=True)

T = train(data_fname)

print(" done.")


# Quantize the transition matrix to 8-bit integers

T_quantized = quantize_transition_matrix(T)


# Export the quantized transition matrix to a C header file.

print("")
print("Exporting quantized transition matrix...", flush=True)

c_matrix = f"#define VOCAB_SIZE {T_quantized.shape[0]} // number of states in the transition matrix\n\n"

c_matrix += f"const uint8_t T[VOCAB_SIZE][VOCAB_SIZE] = "
c_matrix += '{\n'

for i in range(T_quantized.shape[0]):

    c_matrix += '  {'

    for j in range(T_quantized.shape[1]):

        x = int(T_quantized[i][j])
        c_matrix += str(x)

        if j < T_quantized.shape[1] - 1:
            c_matrix += ','
        else:
            c_matrix += '}'
        
    if i < T_quantized.shape[0] - 1:
        c_matrix += ','

    c_matrix += '\n'

c_matrix += '};\n'

with open(export_dev, 'w') as f:
    f.write(c_matrix)

print(f"\t{export_dev}")

with open(export_vanilla, 'w') as f:
    f.write(c_matrix)

print(f"\t{export_vanilla}")

# ...and to a .asm file.

asm_matrix = '.export TransitionMatrix\n'
asm_matrix += '.segment "BANK_0E_T"\n\n'

asm_matrix += "; Transition matrix for bigram model\n"
asm_matrix += "TransitionMatrix:\n"

for i in range(T_quantized.shape[0]):
    asm_matrix += '  .byte '
    for j in range(T_quantized.shape[1]):
        asm_matrix += f'${int(T_quantized[i][j]):02x}'
        if j < T_quantized.shape[1] - 1:
            asm_matrix += ', '
    asm_matrix += '\n'

with open(export_asm, 'w') as f:
    f.write(asm_matrix)

print(f"\t{export_asm}")

print("done.")
