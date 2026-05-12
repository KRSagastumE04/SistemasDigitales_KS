#include "keypad.h"

/* Mapa físico real */
static const char KP_MAP[4][4] = {
    {'1','2','3','A'},
    {'4','5','6','B'},
    {'7','8','9','C'},
    {'*','0','#','D'}
};

volatile uint8_t kp_row_seq    = 0;
volatile uint8_t kp_lock       = 0;
volatile uint8_t kp_row_active = 0;
volatile uint8_t kp_key        = 0xFF;
volatile uint8_t kp_pressed    = 0;

uint8_t kp_cols_all_high(void) {
    uint32_t idrB = GPIOB->IDR;
    uint32_t idrC = GPIOC->IDR;

    uint8_t c0 = (uint8_t)((idrB >> KP_COL0_PIN) & 1u);
    uint8_t c1 = (uint8_t)((idrB >> KP_COL1_PIN) & 1u);
    uint8_t c2 = (uint8_t)((idrC >> KP_COL2_PIN) & 1u);
    uint8_t c3 = (uint8_t)((idrC >> KP_COL3_PIN) & 1u);

    return (uint8_t)(c0 & c1 & c2 & c3);
}

uint8_t keypad_getkey(void) {
    if (!kp_pressed) return 0;

    kp_pressed = 0;
    return kp_key;
}

void keypad_tick(void) {

    if (!kp_lock) {

        uint8_t col = 0xFF;

        if      (!(GPIOB->IDR & (1u << KP_COL0_PIN))) col = 0;
        else if (!(GPIOB->IDR & (1u << KP_COL1_PIN))) col = 1;
        else if (!(GPIOC->IDR & (1u << KP_COL2_PIN))) col = 2;
        else if (!(GPIOC->IDR & (1u << KP_COL3_PIN))) col = 3;

        if (col != 0xFF) {

            kp_key     = (uint8_t)KP_MAP[kp_row_active][col];
            kp_pressed = 1;
            kp_lock    = 1;
        }
    }

    if (kp_lock && kp_cols_all_high()) {
        kp_lock = 0;
    }

    kp_row_active = kp_row_seq;

    GPIOB->ODR |= KP_ROW_MASK;

    switch (kp_row_seq) {

        case 0:
            GPIOB->ODR &= ~(1u << KP_ROW0_PIN);
            break;

        case 1:
            GPIOB->ODR &= ~(1u << KP_ROW1_PIN);
            break;

        case 2:
            GPIOB->ODR &= ~(1u << KP_ROW2_PIN);
            break;

        default:
            GPIOB->ODR &= ~(1u << KP_ROW3_PIN);
            break;
    }

    kp_row_seq++;

    if (kp_row_seq >= 4u)
        kp_row_seq = 0u;
}
void keypad_init(void) {

    /* Todas las filas en HIGH */
    GPIOB->ODR |= KP_ROW_MASK;

    kp_row_seq    = 0u;
    kp_lock       = 0u;
    kp_row_active = 0u;
    kp_key        = 0u;
    kp_pressed    = 0u;
}
