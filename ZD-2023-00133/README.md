批踢踢實業坊(PTT) 註冊驗證碼繞過
--------------------------------

使用不安全的隨機函式生成驗證碼，導致可以使用任意信箱註冊 


原始碼: https://github.com/ptt/pttbbs
PTT 目前有三種註冊方式：人工註冊、信箱註冊（僅限台大信箱）及簡訊註冊。

若用信箱註冊，則必須是 @ntu.edu.tw 結尾。並會生成11個字元的隨機驗證碼寄至該信箱。

但因為使用的隨機函式是 glibc 的 random()，在 seed 只有 2^32 種可能的情況下可以暴力破解。

mbbsd/mbbsd.c:361:
```cpp
static void
mysrand(void)
{
    unsigned int seed;
    must_getrandom(&seed, sizeof(seed));
    seed ^= getpid();
    srandom(seed);
}
```

這裡使用 pmore 下的動畫功能，會提供跳至隨機頁數的功能。
因此只要發一篇有 16 個隨機頁面的 ansi 動畫即可知道 (random() % 16) 的值。
生成 10 個數後，就可以暴力撞出 seed。

mbbsd/pmore.c:4192
```cpp
            if (igs)
            {
                // make random
                igs = random() % (igs+1);

                for (pe = p ; igs > 0 && pe < end && *pe &&
                        *pe > ' ' && *pe < 0x80
                        ; pe ++)
                    if (*pe == ',') igs--;

                if (pe != p)
                    p = pe-1;
            }
```

圖片

(有 16 個隨機頁面的 ansi 動畫)

找出 seed 後，之後所有的 random() 都可以預測結果

到註冊頁面，填入以 @ntu.edu.tw 結尾的任意信箱，
接著算出當次的驗證碼並輸入即可成功註冊。

mbbsd/register.c:262:
```
static void
makeregcode(char *buf)
{
    int     i;
    // prevent ambigious characters: oOlI
    const char *alphabet = "qwertyuipasdfghjkzxcvbnmoQWERTYUPASDFGHJKLZXCVBNM";

    /* generate a new regcode */
    buf[REGCODE_LEN] = 0;
    buf[0] = REGCODE_INITIAL[0];
    buf[1] = REGCODE_INITIAL[1];
    for( i = 2 ; i < REGCODE_LEN ; ++i )
        buf[i] = alphabet[random() % strlen(alphabet)];
}
```

圖片

(成功以不存在的台大信箱註冊)

