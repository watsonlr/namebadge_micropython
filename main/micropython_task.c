/*
 * MicroPython Task Entry Point
 * 
 * This file provides the minimal integration between ESP-IDF and MicroPython.
 * The actual MicroPython implementation will be linked from the micropython component.
 */

#include "py/compile.h"
#include "py/runtime.h"
#include "py/repl.h"
#include "py/gc.h"
#include "py/mperrno.h"
#include "py/stackctrl.h"
#include "shared/runtime/pyexec.h"
#include "shared/readline/readline.h"

// Allocate memory for the MicroPython heap
#if CONFIG_SPIRAM
#include "esp_psram.h"
static uint8_t *mp_heap;
static size_t mp_heap_size = 1024 * 1024;  // 1MB heap in PSRAM
#else
static uint8_t mp_heap[512 * 1024];  // 512KB heap in internal RAM
static size_t mp_heap_size = sizeof(mp_heap);
#endif

void mp_task(void *pvParameter)
{
    #if CONFIG_SPIRAM
    // Allocate MicroPython heap from PSRAM if available
    mp_heap = heap_caps_malloc(mp_heap_size, MALLOC_CAP_SPIRAM);
    if (mp_heap == NULL) {
        printf("Failed to allocate MicroPython heap from PSRAM\n");
        vTaskDelete(NULL);
        return;
    }
    printf("MicroPython heap: %d bytes in PSRAM\n", mp_heap_size);
    #else
    printf("MicroPython heap: %d bytes in internal RAM\n", mp_heap_size);
    #endif

    // Initialize MicroPython
    mp_stack_ctrl_init();
    mp_stack_set_limit(10 * 1024);  // 10KB stack limit for Python code
    
    gc_init(mp_heap, mp_heap + mp_heap_size);
    mp_init();

    // Execute boot.py and main.py if they exist
    // For REPL-only mode, we skip this or handle errors gracefully
    pyexec_file_if_exists("boot.py");
    pyexec_file_if_exists("main.py");

    // Start the REPL
    for (;;) {
        if (pyexec_mode_kind == PYEXEC_MODE_RAW_REPL) {
            if (pyexec_raw_repl() != 0) {
                break;
            }
        } else {
            if (pyexec_friendly_repl() != 0) {
                break;
            }
        }
    }

    // Clean up (this will only execute if REPL exits, which is rare)
    mp_deinit();
    
    #if CONFIG_SPIRAM
    heap_caps_free(mp_heap);
    #endif
    
    vTaskDelete(NULL);
}
