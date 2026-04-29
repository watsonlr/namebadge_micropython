/*
 * BYUI eBadge V3.0 - MicroPython REPL Application
 * 
 * This application boots directly into MicroPython REPL mode,
 * providing an interactive Python environment with access to
 * all badge hardware (display, buttons, LEDs, sensors, etc.)
 */

#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_chip_info.h"
#include "esp_flash.h"

static const char *TAG = "micropython_repl";

// Forward declaration of MicroPython main entry point
extern void mp_task(void *pvParameter);

void print_banner(void)
{
    printf("\n");
    printf("╔═══════════════════════════════════════════════════════════╗\n");
    printf("║     BYUI eBadge V3.0 - MicroPython REPL Environment      ║\n");
    printf("╚═══════════════════════════════════════════════════════════╝\n");
    printf("\n");

    // Print chip information
    esp_chip_info_t chip_info;
    esp_chip_info(&chip_info);
    
    printf("Hardware: ESP32-S3 (revision v%d.%d)\n", 
           chip_info.revision / 100, chip_info.revision % 100);
    printf("Cores: %d\n", chip_info.cores);
    printf("Features: WiFi%s%s\n",
           (chip_info.features & CHIP_FEATURE_BLE) ? " + BLE" : "",
           (chip_info.features & CHIP_FEATURE_BT) ? " + BT" : "");
    
    uint32_t flash_size;
    if (esp_flash_get_size(NULL, &flash_size) == ESP_OK) {
        printf("Flash: %lu MB\n", flash_size / (1024 * 1024));
    }
    
    printf("Free heap: %lu bytes\n", esp_get_free_heap_size());
    printf("\n");
    printf("Starting MicroPython REPL...\n");
    printf("Type help() for more information.\n");
    printf("\n");
}

void app_main(void)
{
    // Initialize NVS (required for WiFi and other services)
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_LOGW(TAG, "NVS partition was truncated, erasing...");
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    ESP_LOGI(TAG, "NVS initialized");

    // Print welcome banner
    print_banner();

    // Create MicroPython task
    // MicroPython needs a larger stack, especially with PSRAM available
    xTaskCreate(mp_task, 
                "mp_task",
                16 * 1024,      // 16KB stack
                NULL, 
                5,               // Priority
                NULL);

    ESP_LOGI(TAG, "MicroPython task created");
}
