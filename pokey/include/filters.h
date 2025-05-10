#ifndef FILTERS_H
#define FILTERS_H

#include <cstdint>
#include <vector>
#include <memory>

// High-pass filter implementation
class HighPassFilter {
private:
    double alpha;
    float prev_input;
    float prev_output;

public:
    HighPassFilter(double time_const, int freq);
    ~HighPassFilter() = default;
    
    float get(float input);
};

// Abstract base class for all filters
class FilterBase {
public:
    virtual ~FilterBase() = default;
    virtual void add_sample(float value) = 0;
    virtual float get() = 0;
};

// Base FIR filter implementation
class FIRFilter : public FilterBase {
protected:
    std::vector<float> coefficients;
    std::vector<float> buffer;
    int current_pos;

public:
    FIRFilter(const std::vector<float>& coeffs);
    virtual ~FIRFilter() = default;
    
    virtual void add_sample(float value) override;
    virtual float get() override;
    float get_last();
};

// Half-band FIR filter
class FIRHalfBandFilter : public FIRFilter {
public:
    FIRHalfBandFilter(const std::vector<float>& coeffs);
    float get() override;
};

// Composite filter: 40:1 decimation
class Filter_Cascade_40_1 : public FIRFilter {
private:
    int sample_cnt;
    std::unique_ptr<FIRHalfBandFilter> fir2_1;
    std::unique_ptr<FIRHalfBandFilter> fir2_2;
    std::unique_ptr<FIRHalfBandFilter> fir2_3;
    std::unique_ptr<FIRFilter> fir5;

public:
    Filter_Cascade_40_1();
    ~Filter_Cascade_40_1() = default;
    
    void add_sample(float value) override;
    float get() override;
};

// Composite filter: 32:1 decimation
class Filter_Cascade_32_1 : public FIRFilter {
private:
    int sample_cnt;
    std::unique_ptr<FIRHalfBandFilter> fir2_1;
    std::unique_ptr<FIRHalfBandFilter> fir2_2;
    std::unique_ptr<FIRHalfBandFilter> fir2_3;
    std::unique_ptr<FIRHalfBandFilter> fir2_4;
    std::unique_ptr<FIRFilter> fir2_5;

public:
    Filter_Cascade_32_1();
    ~Filter_Cascade_32_1() = default;
    
    void add_sample(float value) override;
    float get() override;
};

// Filter coefficient arrays
extern const std::vector<float> FIR_HALF_BAND;
extern const std::vector<float> FIR_5_TO_1;
extern const std::vector<float> FIR_37_to_1;

#endif // FILTERS_H