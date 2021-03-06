#include "imxrt1062.h"
#include <vector>
#include <string>
#include <map>

// These functions come from memset.S and memcpy-armv7m.S
// They are "fast" assembly implementations of memset and memcpy
extern "C" void *memset(void *s, int c, size_t n);
extern "C" void *memcpy (void *dst, const void *src, size_t count);

int main(void)
{
    float x = 3.24f;
    x++;
    // Create a vector of 256 bytes -- proof we can use STL!
    std::vector<uint8_t> test_vector(256);

    // Create a map for the hell of it
    std::map<std::string, int> test_map;
    test_map["zero"] = 0;
    test_map["one"] = 1;

    std::vector<std::string> string_vec;
    string_vec.push_back("how many character is this, i don't know?");

    // Test our fast memset assembly function
    // by setting all the values in the vector to size of vector
    for (size_t i = 0; i < test_vector.size()/8; i++)
    {
        memset(test_vector.data() + i * 8, string_vec.size() * test_map["one"], test_vector.size()/8);
    }
    
    // Configure GPIO B0_03 (PIN 13) for output
    IOMUXC_SW_MUX_CTL_PAD_GPIO_B0_03 = 5;
    IOMUXC_SW_PAD_CTL_PAD_GPIO_B0_03 = IOMUXC_PAD_DSE(7);
    IOMUXC_GPR_GPR27 = 0xFFFFFFFF;
    GPIO7_GDIR |= (1 << 3);

    for(;;) {
        volatile unsigned int i = 0;

        // Set PIN 13 HIGH
        GPIO7_DR_SET = (1 << 3);

        // Poor man's delay
        while(i < 10000000) {
            i++;
        }

        i = 0;

        // Set PIN 13 LOW
        GPIO7_DR_CLEAR = (1 << 3);

        // Poor man's delay
        while(i < 10000000) {
            i++;
        }
    }

    return 0;
}
