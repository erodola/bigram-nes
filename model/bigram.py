import numpy as np
np.random.seed(42)


# Use tokenizing functions because they are easier to convert to C code than a dict

def stoi(c: str) -> int:
  return ord(c) - ord('a') + 1 if c != '.' else 0

def itos(i: int) -> str:
  return chr(i + ord('a') - 1) if i > 0 else '.'

vocab_size = 27  # 26 letters + 1 special character '.'


def train(dataset_fname: str) -> np.ndarray:
  """
  Train a transition matrix from the given dataset.

  The transition matrix is a square matrix where T[i, j] is the probability
  of transitioning from character i to character j.
  
  The vocabulary consists of all characters in the dataset, plus a special
  character '.' which represents the start and end of a name.
  
  Args:
    dataset_fname: Path to the dataset file containing a list of names.
  
  Returns:
    T: Transition matrix.
  """
  names = open(dataset_fname, 'r').read().splitlines()

  # Build bigram dictionary with counts (needed to build the transition matrix)

  bigram_dict = {}

  for word in names:
    word_special = ['.'] + list(word) + ['.']
    bigrams = [pair for pair in zip(word_special, word_special[1:])]
    for b in bigrams:
      bigram_dict[b] = bigram_dict.get(b, 0) + 1

  # Compute transition matrix

  T = np.zeros((vocab_size, vocab_size), dtype=np.float32)

  for bigram, count in bigram_dict.items():
    i, j = stoi(bigram[0]), stoi(bigram[1])
    T[i, j] = count

  sums = T.sum(axis=1, keepdims=True)
  sums[sums == 0.] = 1.
  T /= sums

  return T

def quantize_transition_matrix(T: np.ndarray) -> np.ndarray:
    """
    Quantizes the transition matrix T to UINT8.

    Each row in T is quantized independently, ensuring each sums up to 255.
    
    Instead of dumping the residual into one single bin (e.g. the maximum probability),
    which might add bias and lead to overflow, we distribute the residual across the bins
    with the highest remainders, which ensures minimal total deviation from true probabilities.

    Args:
        T: Transition matrix (floating-point probabilities).
    Returns:
        Quantized transition matrix in UINT8 format.
    """
    T_quantized = np.zeros_like(T, dtype=np.uint8)

    for i in range(T.shape[0]):

      scaled = T[i] * 255
      floored = np.floor(scaled).astype(np.uint8)
      residual = 255 - np.sum(floored, dtype=np.int16)  # might be negative

      if residual > 0:
          remainders = scaled - floored
          indices = np.argsort(-remainders)[:residual]  # get indices of the largest remainders
          floored[indices] += 1

      T_quantized[i] = floored

    return T_quantized

def multinomial_quantized(prob: np.ndarray) -> int:
  """
  A reimplementation of torch.multinomial to only use sums and comparisons (no log or exp).
  Assumes that the input is a probability distribution of raw counts (integers).

  Args:
    prob: Probability distribution of raw counts (integers).
  Returns:
    An index sampled from the multinomial distribution.
  """
  total = int(round(prob.sum()))

  # random number from uniform distribution in [0, total)
  r = np.random.randint(low=0, high=total, size=(1,)).item()

  # inverse transform sampling
  cum = 0
  for i in range(len(prob)):
      cum += prob[i].item()
      if r < cum:
          return i
      
  return len(prob) - 1  # in case of rounding errors, return the last index

def generate_quantized(T_quantized: np.ndarray, min_length: int = 3, max_length: int = 8) -> str:
  """
  Generate a random name based on the input transition matrix and vocabulary.

  Args:
    T_quantized: Quantized transition matrix.
    min_length: Minimum length of the generated name (inclusive).
    max_length: Maximum length of the generated name (inclusive).
    
  Returns:
    A randomly generated name as a string.
  """
  ok = False

  while not ok:

    new_name = ''

    first_token = '.'
    while first_token == '.':
      first_token = itos(multinomial_quantized(T_quantized[0]))

    new_name += first_token

    next_token = first_token
    while next_token != '.':
      next_token = itos(multinomial_quantized(T_quantized[stoi(next_token)]))
      new_name += next_token

    new_name = new_name[:-1]  # remove the last '.' token

    if min_length <= len(new_name) <= max_length:
      ok = True

  return new_name
