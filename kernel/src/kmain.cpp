#include <stl/array.h>
#include <drivers/ps2.hpp>
#include <drivers/vga.hpp>
#include <interrupt.hpp>

extern "C" void interrupt_wrapper();

[[maybe_unused]] constexpr short MAJOR_VERSION = 0;
[[maybe_unused]] constexpr short MINOR_VERSION = 0;
constexpr const char* VERSION_STRING = "0.0";

void write_ff_info(cursor& crs) {
    vga::clear();
    crs << "FireflyOS\nVersion: " << VERSION_STRING << "\nContributors:";

    firefly::std::array<const char*, 7> arr = {
        "Lime\t  ", "JohnkaS", "EyeDevelop", "4lpha", "Burokkoru ", "extation", "RedEye2D"
    };

    for (size_t i = 0; i < arr.max_size(); i++) {
        if (i % 2 == 0) {
            crs << "\n\t";
        }
        crs << arr[i] << "  ";
    }
    crs << "\n";
}

extern "C" [[noreturn]] void kmain(uint64_t bin_size) {
    vga::init();
    interrupt::init();
    vga::clear();

    (void)bin_size;

    cursor crs{ color::white, color::black, 0, 0 };
    write_ff_info(crs);

    while (true)
        ;
}