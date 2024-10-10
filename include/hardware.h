

#ifdef BOARD_REG1_ETH

    #define HARDWARE_NAME "REG1_ETH"

    #define OKNXHW_REG1_ETH
    #include "OpenKNXHardware.h"

    #undef INFO_LED_PIN
    #undef INFO_LED_PIN_ACTIVE_ON

    #define INFO2_LED_PIN 24
    #define INFO2_LED_PIN_ACTIVE_ON HIGH

    #define INFO3_LED_PIN 3
    #define INFO3_LED_PIN_ACTIVE_ON HIGH

#endif

#ifdef BOARD_REG1_ETH_V1

    #define HARDWARE_NAME "REG1_ETH_V1"

    #define OKNXHW_REG1_ETH_V1
    #include "OpenKNXHardware.h"

#endif

#ifdef BOARD_PIPICO

    #define HARDWARE_NAME "PIPICO"

    #define PROG_LED_PIN LED_BUILTIN
    #define PROG_LED_PIN_ACTIVE_ON HIGH
    #define PROG_BUTTON_PIN 7
    #define PROG_BUTTON_PIN_INTERRUPT_ON FALLING
    #define SAVE_INTERRUPT_PIN 6
    #define INFO_LED_PIN 3
    #define INFO_LED_PIN_ACTIVE_ON HIGH
    #define KNX_UART_RX_PIN 1
    #define KNX_UART_TX_PIN 0

    // Definition for PiPico / SPI0
    // #define ETH_SPI_INTERFACE SPI // SPI or SPI1, depends on the pins
    // #define PIN_ETH_MISO (16)
    // #define PIN_ETH_MOSI (19)
    // #define PIN_ETH_SCK (18)
    // #define PIN_ETH_SS (17)

    // Definition for PiPico / SPI1 (default)
    #define ETH_SPI_INTERFACE SPI1 // SPI or SPI1, depends on the pins
    #define PIN_ETH_MISO (12)
    #define PIN_ETH_MOSI (15)
    #define PIN_ETH_SCK (14)
    #define PIN_ETH_SS (13)

    // Definition for PiPico / SPI1
    #define ETH_SPI_INTERFACE SPI1 // SPI or SPI1, depends on the pins
// #define PIN_ETH_MISO (12)
// #define PIN_ETH_MOSI (11)
// #define PIN_ETH_SCK (10)
// #define PIN_ETH_SS (13)

    #define PIN_SD_SS (9)
    #define PIN_ETH_INT (10)
    #define PIN_ETH_RES (11)

#endif

#ifdef BOARD_W5500_EVB_PICO

// https://www.wiznet.io/product-item/w5500-evb-pico/

    #define HARDWARE_NAME "W5500-EVB-PICO"

    #define PROG_LED_PIN LED_BUILTIN
    #define PROG_LED_PIN_ACTIVE_ON HIGH
    #define PROG_BUTTON_PIN 14
    #define PROG_BUTTON_PIN_INTERRUPT_ON FALLING
    #define SAVE_INTERRUPT_PIN 15
    #define INFO_LED_PIN -1
    #define INFO_LED_PIN_ACTIVE_ON HIGH
    #define KNX_UART_RX_PIN 1
    #define KNX_UART_TX_PIN 0

// Definition for PiPico / SPI0

    #define ETH_SPI_INTERFACE SPI // SPI or SPI1, depends on the pins
    #define PIN_ETH_MISO (16)
    #define PIN_ETH_MOSI (19)
    #define PIN_ETH_SCK (18)
    #define PIN_ETH_SS (17)

    #define PIN_SD_SS (22)
    #define PIN_ETH_INT (21)
    #define PIN_ETH_RES (20)

#endif

#ifdef BOARD_PIPICOW

    #define HARDWARE_NAME "PIPICOW"

    #define PROG_LED_PIN LED_BUILTIN
    #define PROG_LED_PIN_ACTIVE_ON HIGH
    #define PROG_BUTTON_PIN 7
    #define PROG_BUTTON_PIN_INTERRUPT_ON FALLING
    #define SAVE_INTERRUPT_PIN 6
    #define INFO_LED_PIN 3
    #define INFO_LED_PIN_ACTIVE_ON HIGH
    #define KNX_UART_RX_PIN 1
    #define KNX_UART_TX_PIN 0

#endif

#ifdef BOARD_REG1_ESP_DEVBOARD_V00_02
    #define HARDWARE_NAME "REG1_ESP_DEV"

    #define PROG_LED_PIN 4
    #define PROG_LED_PIN_ACTIVE_ON HIGH
    #define PROG_BUTTON_PIN 39
    #define PROG_BUTTON_PIN_INTERRUPT_ON FALLING

    #define SAVE_INTERRUPT_PIN 36
    #define KNX_UART_RX_PIN 37
    #define KNX_UART_TX_PIN 14

// #define INFO1_LED_PIN 4
// #define INFO1_LED_PIN_ACTIVE_ON HIGH
// #define INFO2_LED_PIN 4
// #define INFO2_LED_PIN_ACTIVE_ON HIGH
// #define INFO3_LED_PIN 4
// #define INFO3_LED_PIN_ACTIVE_ON HIGH

    #define FUNC1_BUTTON_PIN 38
    #define FUNC2_BUTTON_PIN 34
    #define FUNC3_BUTTON_PIN 35

    #define ETH_PHY_TYPE ETH_PHY_LAN8720 // type of PHY used, needed for IDF
    #define ETH_PHY_ADDR 0               // PHYs I2C address
    #define ETH_PHY_MDC 33
    #define ETH_PHY_MDIO 32
    #define ETH_PHY_POWER 2 // enable / disable the PHYs clock
    #define ETH_CLK_MODE ETH_CLOCK_GPIO0_IN

    #define REG1_APP_PIN1 12
    #define REG1_APP_PIN2 15
    #define REG1_APP_PIN3 13
    #define REG1_APP_PIN4 5
    #define REG1_APP_PIN5 8
    #define REG1_APP_PIN6 7
    #define REG1_APP_PIN7 20

// informative pin usage - Do not use for other purposes
// RMII:
// ETH_PHY_CLK_INPUT_PIN 0
// ETH_PHY_RXD0_PIN 25
// ETH_PHY_RXD1_PIN 26
// ETH_PHY_RX_DV_CRS_PIN 27
// ETH_PHY_TX_EN_PIN 21
// ETH_PHY_TXD0_PIN 19
// ETH_PHY_TXD1_PIN 22
//
// USB:
// USB_UART_TX_PIN 1
// USB_UART_RX_PIN 3
#endif