#define UARTDR 0x9000000

#define MULDEV_RES 0x9009000
#define MULDEV_LHS 0x9009008
#define MULDEV_RHS 0x9009010

typedef unsigned char uint8_t;
typedef long unsigned int uint64_t;

void pl011_putc(const uint8_t c) {
    *(volatile uint8_t *)UARTDR = c;
}

void muldev_set_lhs(const uint64_t n) {
    *(volatile uint64_t *)MULDEV_LHS = n;
}

void muldev_set_rhs(const uint64_t n) {
    *(volatile uint64_t *)MULDEV_RHS = n;
}

uint64_t muldev_get() {
    return *(volatile uint64_t *)MULDEV_RES;
}

void entry() {
    muldev_set_lhs(2);
    muldev_set_rhs(3);
    pl011_putc('0' + muldev_get());
    pl011_putc('\n');
}
