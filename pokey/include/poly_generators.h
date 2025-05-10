#ifndef POLY_GENERATORS_H
#define POLY_GENERATORS_H

#include <cstdint>
#include <vector>

// Base class for polynomial generators
class PolyGenerator {
protected:
    int n_bits;
    int highest_bit;
    int value;

public:
    PolyGenerator(int n_bits);
    virtual ~PolyGenerator() = default;
    
    int8_t next();
    int size() const;
    
    // Create a vector of all values in the sequence
    std::vector<int8_t> generate_sequence();
    
protected:
    virtual int compute(int v, int n_bits, int highest_bit) = 0;
};

// 4-bit polynomial generator
class Poly4 : public PolyGenerator {
public:
    Poly4();
protected:
    int compute(int v, int n_bits, int highest_bit) override;
};

// 5-bit polynomial generator
class Poly5 : public PolyGenerator {
public:
    Poly5();
protected:
    int compute(int v, int n_bits, int highest_bit) override;
};

// 9-bit polynomial generator
class Poly9 : public PolyGenerator {
public:
    Poly9();
protected:
    int compute(int v, int n_bits, int highest_bit) override;
};

// 17-bit polynomial generator
class Poly17 : public PolyGenerator {
public:
    Poly17();
protected:
    int compute(int v, int n_bits, int highest_bit) override;
};

#endif // POLY_GENERATORS_H