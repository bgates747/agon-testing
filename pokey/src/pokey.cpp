#include "pokey.h"
#include <cmath>
#include <stdexcept>

// Define the high-pass filter time constant
const double HIGH_PASS_TIME_CONST = 0.0026;

POKEY::POKEY(int index, int sample_rate) :
    buffer_pos(0),
    index(index),
    divider(0),
    clock_cnt(0),
    audctl(0),
    audf(4, 0),
    audc(4, 0),
    cnt(4, 0),
    square_output(4, 0),
    output(4, 0),
    console(0),
    fast_1(false),
    fast_3(false),
    link12(false),
    link34(false),
    clock_period(0),
    hipass1(0),
    hipass2(0),
    hipass1_flipflop(0),
    hipass2_flipflop(0),
    cycle_cnt(0) {
    
    // Set up the correct filter based on sample rate
    if (sample_rate == 48000) {
        fir_filter = std::make_unique<FIRFilter>(FIR_37_to_1);
        divider    = 37;
    }
    else if (sample_rate == 44100) {
        fir_filter = std::make_unique<Filter_Cascade_40_1>();
        divider    = 40;
    }
    else if (sample_rate == 56000) {
        fir_filter = std::make_unique<Filter_Cascade_32_1>();
        divider    = 32;
    }
    else {
        throw std::runtime_error("Invalid sample rate: " + std::to_string(sample_rate));
    }
    
    high_pass_filter = std::make_unique<HighPassFilter>(HIGH_PASS_TIME_CONST, sample_rate);
    
    // Initial AUDCTL setup
    set_audctl(0);
    
    // Generate polynomial sequences
    Poly4 poly4;
    Poly5 poly5;
    Poly9 poly9;
    Poly17 poly17;
    
    poly_4 = poly4.generate_sequence();
    poly_5 = poly5.generate_sequence();
    poly_9 = poly9.generate_sequence();
    poly_17 = poly17.generate_sequence();
}

POKEY::~POKEY() {
    // All resources are managed by smart pointers and STL containers
}

void POKEY::feed(const std::vector<uint8_t>& data) {
    buffer.insert(buffer.end(), data.begin(), data.end());
}

void POKEY::truncateBuffer() {
    if (buffer_pos > 0) {
        buffer.erase(buffer.begin(), buffer.begin() + buffer_pos);
        buffer_pos = 0;
    }
}

void POKEY::processEvents(double currentFrame) {
    while (buffer_pos + 2 < buffer.size() && 
           buffer[buffer_pos + 2] <= currentFrame) {
        
        int index = buffer[buffer_pos] & 0xf;
        uint8_t value = buffer[buffer_pos + 1];
        
        if (index == 8) {
            set_audctl(value);
        }
        else if (index == 9) {
            set_console(value);
        }
        else if ((index & 1) == 0) {
            set_audf(index >> 1, value);
        }
        else {
            set_audc(index >> 1, value);
        }
        
        buffer_pos += 3;
    }
}

void POKEY::set_audctl(uint8_t value) {
    audctl = value;
    fast_1 = (value & 0x40) > 0;
    fast_3 = (value & 0x20) > 0;
    link12 = (value & 0x10) > 0;
    link34 = (value & 0x8) > 0;
    clock_period = (value & 1) ? 114 : 28;
    hipass1 = (value >> 2) & 1;
    hipass2 = (value >> 1) & 1;
    hipass1_flipflop |= !hipass1;
    hipass2_flipflop |= !hipass2;
}

void POKEY::set_audf(int index, uint8_t value) {
    audf[index] = value;
}

void POKEY::set_audc(int index, uint8_t value) {
    audc[index] = value;
}

void POKEY::set_console(uint8_t value) {
    console = value & 1;
}

int POKEY::get_poly_output(int k, const std::vector<int8_t>& poly) {
    return poly[(cycle_cnt + k) % poly.size()];
}

int POKEY::get_output(int k) {
    uint8_t audc_val = audc[k];
    
    if (audc_val & 0x20) {
        return square_output[k];
    }
    else {
        if (audc_val & 0x40) {
            return get_poly_output(k, poly_4);
        }
        else {
            if (audctl & 0x80) {
                return get_poly_output(k, poly_9);
            }
            else {
                return get_poly_output(k, poly_17);
            }
        }
    }
}

void POKEY::set_output(int k) {
    if (audc[k] & 0x80 || get_poly_output(k, poly_5)) {
        square_output[k] = (~square_output[k]) & 1;
    }
    output[k] = get_output(k);
}

void POKEY::reload_single(int k) {
    int fast_delay = ((k == 0 && fast_1) || (k == 2 && fast_3)) ? 3 : 0;
    cnt[k] = audf[k] + fast_delay;
    set_output(k);
}

void POKEY::reload_linked(int k) {
    int cnt_val = audf[k] + 256 * audf[k + 1] + 6;
    cnt[k] = cnt_val & 0xff;
    cnt[k + 1] = cnt_val >> 8;
    set_output(k + 1);
}

float POKEY::get() {
    for (int j = 0; j < divider; j++) {
        clock_cnt -= 1;
        bool clock_underflow = clock_cnt < 0;
        
        if (clock_underflow) {
            clock_cnt = clock_period - 1;
        }
        
        if (!link12) {
            if (fast_1 || clock_underflow) {
                cnt[0] -= 1;
                if (cnt[0] < 0) reload_single(0);
            }
            if (clock_underflow) {
                cnt[1] -= 1;
                if (cnt[1] < 0) reload_single(1);
            }
        }
        else {
            if (fast_1 || clock_underflow) {
                cnt[0] -= 1;
                if (cnt[0] < 0) {
                    cnt[0] = 255;
                    set_output(0);
                    cnt[1] -= 1;
                    if (cnt[1] < 0) reload_linked(0);
                }
            }
        }
        
        if (!link34) {
            if (fast_3 || clock_underflow) {
                cnt[2] -= 1;
                if (cnt[2] < 0) {
                    reload_single(2);
                    if (hipass1) {
                        hipass1_flipflop = output[0];
                    }
                }
            }
            if (clock_underflow) {
                cnt[3] -= 1;
                if (cnt[3] < 0) {
                    reload_single(3);
                    if (hipass2) {
                        hipass2_flipflop = output[1];
                    }
                }
            }
        }
        else {
            if (fast_3 || clock_underflow) {
                cnt[2] -= 1;
                if (cnt[2] < 0) {
                    // what about hipass1 / hipass2 here?
                    cnt[2] = 255;
                    set_output(2);
                    cnt[3] -= 1;
                    if (cnt[3] < 0) reload_linked(2);
                }
            }
        }
        
        cycle_cnt += 1;
        
        auto vol_only = [this](int n) { return (audc[n] >> 4) & 1; };
        auto vol = [this](int n) { return audc[n] & 15; };
        
        int ch1 = ( (hipass1_flipflop ^ output[0]) & 1 ) | vol_only(0);
        int ch2 = ( (hipass2_flipflop ^ output[1]) & 1 ) | vol_only(1);
        int ch3 = ( output[2]               & 1 ) | vol_only(2);
        int ch4 = ( output[3]               & 1 ) | vol_only(3);        
        
        auto normalizeAltirra = [](float vol) { 
            return (1.0f - std::exp(-2.9f * (vol / 64.0f))) / (1.0f - std::exp(-2.9f)); 
        };
        
        float sample = normalizeAltirra(
            ch1 * vol(0) + ch2 * vol(1) + ch3 * vol(2) + ch4 * vol(3) + console * 4
        );
        
        fir_filter->add_sample(sample);
    }
    
    return high_pass_filter->get(fir_filter->get());
}

// C wrapper functions for FFI
extern "C" {
    POKEY* pokey_create(int sample_rate) {
        return new POKEY(0, sample_rate);
    }
    
    void pokey_destroy(POKEY* pokey) {
        delete pokey;
    }
    
    void pokey_set_audctl(POKEY* pokey, uint8_t value) {
        pokey->set_audctl(value);
    }
    
    void pokey_set_audf(POKEY* pokey, int channel, uint8_t value) {
        pokey->set_audf(channel, value);
    }
    
    void pokey_set_audc(POKEY* pokey, int channel, uint8_t value) {
        pokey->set_audc(channel, value);
    }
    
    void pokey_set_console(POKEY* pokey, uint8_t value) {
        pokey->set_console(value);
    }
    
    void pokey_feed(POKEY* pokey, const uint8_t* buffer, int buffer_size) {
        std::vector<uint8_t> data(buffer, buffer + buffer_size);
        pokey->feed(data);
    }
    
    void pokey_process_events(POKEY* pokey, double current_frame) {
        pokey->processEvents(current_frame);
    }
    
    float pokey_get_sample(POKEY* pokey) {
        return pokey->get();
    }
    
    void pokey_generate_samples(POKEY* pokey, float* buffer, int num_samples) {
        for (int i = 0; i < num_samples; i++) {
            buffer[i] = pokey->get();
        }
    }
}