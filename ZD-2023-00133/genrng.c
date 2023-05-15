#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

const char* alphabet = "qwertyuipasdfghjkzxcvbnmoQWERTYUPASDFGHJKLZXCVBNM";

int main() {
    uint32_t seed;
    scanf("%u", &seed);
    srandom(seed);
    for (int i = 0; i < 12; i++)
        printf("$ %ld\n", random() % 16);
    int v;
    while (~scanf("%d", &v)) {
        long r = random();
        printf("$ %ld (16:%ld) (49:%c) (fff:%lx)\n", r, r % 16, alphabet[r%49], r&0xfff);
    }
    return 0;
}
