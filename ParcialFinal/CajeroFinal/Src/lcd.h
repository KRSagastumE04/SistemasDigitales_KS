/*
 * lcd.h
 * Driver para LCD 16x2 HD44780 en modo 4 bits.
 *
 * Conexion de pines:
 *   RS -> PC0  (Register Select)
 *   EN -> PC1  (Enable)
 *   D4 -> PC2  (dato bit 4)
 *   D5 -> PC3  (dato bit 5)
 *   D6 -> PC4  (dato bit 6)
 *   D7 -> PC5  (dato bit 7)
 *   RW -> GND  (siempre escritura)
 */
#ifndef LCD_H
#define LCD_H

#include <stdint.h>
#include "stm32l053xx.h"

/* Pines de control - todos en GPIOC */
#define LCD_RS_PORT   GPIOC
#define LCD_RS_PIN    0u   /* Register Select: 0=cmd, 1=dato */

#define LCD_EN_PORT   GPIOC
#define LCD_EN_PIN    1u   /* Enable: pulso para latch de datos */

/* Pines de datos (modo 4 bits, D4-D7) - todos en GPIOC */
#define LCD_D4_PORT   GPIOC
#define LCD_D4_PIN    2u   /* bit 4 */

#define LCD_D5_PORT   GPIOC
#define LCD_D5_PIN    3u   /* bit 5 */

#define LCD_D6_PORT   GPIOC
#define LCD_D6_PIN    4u   /* bit 6 */

#define LCD_D7_PORT   GPIOC
#define LCD_D7_PIN    5u   /* bit 7 */

/* Mascara de todos los pines LCD en GPIOC */
#define LCD_PIN_MASK  ((1u<<LCD_RS_PIN)|(1u<<LCD_EN_PIN)| \
                       (1u<<LCD_D4_PIN)|(1u<<LCD_D5_PIN)| \
                       (1u<<LCD_D6_PIN)|(1u<<LCD_D7_PIN))

/* Funciones publicas */
void lcd_init(void);
void lcd_cmd(uint8_t cmd);
void lcd_data(uint8_t ch);
void lcd_set_cursor(uint8_t col, uint8_t row);
void lcd_print(const char *str);
void lcd_clear(void);
void lcd_print_line(uint8_t row, const char *str);

#endif /* LCD_H */
