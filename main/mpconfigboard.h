/*
 * MicroPython Configuration for BYUI eBadge V3.0
 * 
 * This file defines board-specific MicroPython configuration options.
 */

// Board name
#define MICROPY_HW_BOARD_NAME "BYUI eBadge V3.0"
#define MICROPY_HW_MCU_NAME "ESP32-S3"

// Enable ESP32-specific features
#define MICROPY_PY_MACHINE (1)
#define MICROPY_PY_NETWORK (1)
#define MICROPY_PY_BLUETOOTH (1)

// Hardware configuration
#define MICROPY_HW_ENABLE_UART_REPL (1)

// GPIO Pin definitions for badge peripherals
// Display (ILI9341)
#define DISPLAY_SPI_HOST    SPI2_HOST
#define DISPLAY_PIN_CS      9
#define DISPLAY_PIN_DC      13
#define DISPLAY_PIN_RST     48
#define DISPLAY_PIN_CLK     12
#define DISPLAY_PIN_MOSI    11
#define DISPLAY_PIN_MISO    10

// SD Card
#define SD_PIN_CS           3

// Buttons
#define BUTTON_UP           17
#define BUTTON_DOWN         16
#define BUTTON_LEFT         14
#define BUTTON_RIGHT        15
#define BUTTON_A            38
#define BUTTON_B            18
#define BUTTON_BOOT         0

// RGB LED
#define LED_RED             6
#define LED_GREEN           5
#define LED_BLUE            4

// Addressable LEDs (WS2813B)
#define LED_STRIP_PIN       7

// Buzzer
#define BUZZER_PIN          42

// I2C (Accelerometer MMA8452Q)
#define I2C_SDA             47
#define I2C_SCL             21

// Joystick (ADC)
#define JOYSTICK_X          1
#define JOYSTICK_Y          2

// USB
#define USB_DN              19
#define USB_DP              20
