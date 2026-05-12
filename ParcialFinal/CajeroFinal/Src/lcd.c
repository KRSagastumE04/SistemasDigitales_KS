/*
 * lcd.c
 * Driver para LCD 16x2 HD44780 en modo 4 bits.
 * Todos los pines en GPIOC (RS=PC0, EN=PC1, D4=PC2, D5=PC3, D6=PC4, D7=PC5).
 */
#include "lcd.h"

extern void delayMs(uint16_t n);

/* ------------------------------------------------------------------ */
/* Funciones internas                                                   */
/* ------------------------------------------------------------------ */

static void lcd_set_rs(uint8_t v) {
    if (v) LCD_RS_PORT->BSRR = (1u << LCD_RS_PIN);
    else   LCD_RS_PORT->BSRR = (1u << (LCD_RS_PIN + 16u));
}

static void lcd_set_en(uint8_t v) {
    if (v) LCD_EN_PORT->BSRR = (1u << LCD_EN_PIN);
    else   LCD_EN_PORT->BSRR = (1u << (LCD_EN_PIN + 16u));
}

static void lcd_pulse_en(void) {
    lcd_set_en(1);
    for (volatile uint16_t i = 0; i < 20; i++);
    lcd_set_en(0);
    for (volatile uint16_t i = 0; i < 20; i++);
}

/*
 * lcd_write_nibble - escribe 4 bits en D4-D7 y pulsa EN.
 * nibble bits: 0->D4, 1->D5, 2->D6, 3->D7
 */
static void lcd_write_nibble(uint8_t nibble) {
    if (nibble & 0x01) LCD_D4_PORT->BSRR = (1u << LCD_D4_PIN);
    else               LCD_D4_PORT->BSRR = (1u << (LCD_D4_PIN + 16u));

    if (nibble & 0x02) LCD_D5_PORT->BSRR = (1u << LCD_D5_PIN);
    else               LCD_D5_PORT->BSRR = (1u << (LCD_D5_PIN + 16u));

    if (nibble & 0x04) LCD_D6_PORT->BSRR = (1u << LCD_D6_PIN);
    else               LCD_D6_PORT->BSRR = (1u << (LCD_D6_PIN + 16u));

    if (nibble & 0x08) LCD_D7_PORT->BSRR = (1u << LCD_D7_PIN);
    else               LCD_D7_PORT->BSRR = (1u << (LCD_D7_PIN + 16u));

    lcd_pulse_en();
}

/* Envia byte completo: nibble alto primero, luego nibble bajo. */
static void lcd_send(uint8_t value, uint8_t rs) {
    lcd_set_rs(rs);
    lcd_write_nibble(value >> 4);
    for (volatile uint16_t i = 0; i < 20; i++);
    lcd_write_nibble(value & 0x0F);
    for (volatile uint16_t i = 0; i < 20; i++);
}

/* ------------------------------------------------------------------ */
/* Funciones publicas                                                   */
/* ------------------------------------------------------------------ */

void lcd_cmd(uint8_t cmd)   { lcd_send(cmd, 0); }
void lcd_data(uint8_t ch)   { lcd_send(ch,  1); }

void lcd_set_cursor(uint8_t col, uint8_t row) {
    uint8_t addr = (row == 0) ? (0x80u + col) : (0xC0u + col);
    lcd_cmd(addr);
}

void lcd_print(const char *str) {
    while (*str) lcd_data((uint8_t)*str++);
}

void lcd_clear(void) {
    lcd_cmd(0x01);
    delayMs(2);
}

/*
 * lcd_print_line - imprime hasta 16 chars en la fila indicada,
 * rellenando con espacios para borrar contenido anterior.
 */
void lcd_print_line(uint8_t row, const char *str) {
    lcd_set_cursor(0, row);
    uint8_t i = 0;
    while (str[i] && i < 16) {
        lcd_data((uint8_t)str[i]);
        i++;
    }
    while (i < 16) {
        lcd_data(' ');
        i++;
    }
}

/*
 * lcd_init - inicializa el LCD segun datasheet HD44780.
 * Llamar UNA SOLA VEZ al inicio, antes de habilitar interrupciones
 * (o al menos antes de que TIM22 empiece a usarlo).
 */
void lcd_init(void) {
    delayMs(100);

    lcd_set_rs(0);
    lcd_set_en(0);

    /* Secuencia de reset por software */
    lcd_write_nibble(0x03); delayMs(10);
    lcd_write_nibble(0x03); delayMs(5);
    lcd_write_nibble(0x03); delayMs(1);
    lcd_write_nibble(0x02); delayMs(1);  /* modo 4 bits */

    lcd_cmd(0x28); delayMs(1);  /* 4 bits, 2 lineas, fuente 5x8 */
    lcd_cmd(0x0C); delayMs(1);  /* display ON, cursor OFF */
    lcd_cmd(0x06); delayMs(1);  /* incremento automatico */
    lcd_cmd(0x01);              /* limpiar display */
    delayMs(5);
}
