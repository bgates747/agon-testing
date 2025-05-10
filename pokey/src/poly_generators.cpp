#include "poly_generators.h"

// Base PolyGenerator implementation
PolyGenerator::PolyGenerator(int n_bits) : n_bits(n_bits) {
    highest_bit = 1 << (n_bits - 1);
    value = highest_bit;
}

int8_t PolyGenerator::next() {
    int8_t v = value & 1;
    value = compute(value, n_bits, highest_bit);
    return v;
}

int PolyGenerator::size() const {
    return (1 << n_bits) - 1;
}

std::vector<int8_t> PolyGenerator::generate_sequence() {
    std::vector<int8_t> result(size());
    for (int i = 0; i < size(); i++) {
        result[i] = next();
    }
    return result;
}

// Poly4 implementation
Poly4::Poly4() : PolyGenerator(4) {}

int Poly4::compute(int v, int /* n_bits */, int /* highest_bit */) {
    return ((v + v)) + (~((v >> 2) ^ (v >> 3)) & 1);
}

// Poly5 implementation
Poly5::Poly5() : PolyGenerator(5) {}

int Poly5::compute(int v, int /* n_bits */, int /* highest_bit */) {
    return ((v + v)) + (~((v >> 2) ^ (v >> 4)) & 1);
}

// Poly9 implementation
Poly9::Poly9() : PolyGenerator(9) {}

int Poly9::compute(int v, int /* n_bits */, int /* highest_bit */) {
    return ((v >> 1)) + (((v << 8) ^ (v << 3)) & 0x100);
}

// Poly17 implementation
Poly17::Poly17() : PolyGenerator(17) {}

int Poly17::compute(int v, int /* n_bits */, int /* highest_bit */) {
    return ((v >> 1)) + (((v << 16) ^ (v << 11)) & 0x10000);
}