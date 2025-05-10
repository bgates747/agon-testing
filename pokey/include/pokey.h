#ifndef POKEY_H
#define POKEY_H

#include <cstdint>
#include <vector>
#include <memory>
#include "filters.h"
#include "poly_generators.h"

class POKEY {
public:
    POKEY(int index, int sample_rate = 44100);
    ~POKEY();

    // Feed data into the buffer
    void feed(const std::vector<uint8_t>& data);
    
    // Remove processed events from buffer
    void truncateBuffer();
    
    // Process events up to currentFrame
    void processEvents(double currentFrame);
    
    // Generate one sample
    float get();
    
    // POKEY register setters
    void set_audctl(uint8_t value);
    void set_audf(int index, uint8_t value);
    void set_audc(int index, uint8_t value);
    void set_console(uint8_t value);

private:
    // Buffer management
    std::vector<uint8_t> buffer;
    std::vector<uint8_t>::size_type buffer_pos;
    
    // POKEY state
    int index;
    int divider;

    // before:
    // std::unique_ptr<FIRFilter>      fir_filter;
    // after:
    std::unique_ptr<FilterBase>     fir_filter;
    // end changes

    std::unique_ptr<HighPassFilter> high_pass_filter;
    int clock_cnt;
    
    // POKEY registers
    uint8_t audctl;
    std::vector<uint8_t> audf;
    std::vector<uint8_t> audc;
    std::vector<int> cnt;
    std::vector<int> square_output;
    std::vector<int> output;
    int console;
    
    // AUDCTL flags
    bool fast_1;
    bool fast_3;
    bool link12;
    bool link34;
    int clock_period;
    int hipass1;
    int hipass2;
    int hipass1_flipflop;
    int hipass2_flipflop;
    
    // Polynomials
    std::vector<int8_t> poly_4;
    std::vector<int8_t> poly_5;
    std::vector<int8_t> poly_9;
    std::vector<int8_t> poly_17;
    int cycle_cnt;
    
    // Helper methods
    int get_poly_output(int k, const std::vector<int8_t>& poly);
    int get_output(int k);
    void set_output(int k);
    void reload_single(int k);
    void reload_linked(int k);
};

// C-compatible wrapper functions for FFI
extern "C" {
    POKEY* pokey_create(int sample_rate);
    void pokey_destroy(POKEY* pokey);
    void pokey_set_audctl(POKEY* pokey, uint8_t value);
    void pokey_set_audf(POKEY* pokey, int channel, uint8_t value);
    void pokey_set_audc(POKEY* pokey, int channel, uint8_t value);
    void pokey_set_console(POKEY* pokey, uint8_t value);
    void pokey_feed(POKEY* pokey, const uint8_t* buffer, int buffer_size);
    void pokey_process_events(POKEY* pokey, double current_frame);
    float pokey_get_sample(POKEY* pokey);
    void pokey_generate_samples(POKEY* pokey, float* buffer, int num_samples);
}

#endif // POKEY_H