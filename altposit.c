#include "altposit.h"
#include "altposit_p8.c"
#include "altposit_p16.c"
#include "altposit_p32.c"
#include <math.h>
#define CONCAT(a, b) a##b
#define XCONCAT(a, b) CONCAT(a, b)

#define wrapop(a,b,op,tof,fromf)  fromf(op(tof(a),tof(b))
#define convert(a,fromt,tot) XCONCAT(convertDoubleToP,tot)(XCONCAT(XCONCAT(convertP,fromt),ToDouble)(a))

// uses 

posit16_t p16_sqrt(posit16_t x) { return convertDoubleToP16(sqrt(convertP16ToDouble(x)));}
posit32_t p32_sqrt(posit32_t x) { return convertDoubleToP32(sqrt(convertP32ToDouble(x)));}
posit8_t p8_sqrt(posit8_t x) { return convertDoubleToP8(sqrt(convertP8ToDouble(x)));}

double convertP16ToDouble(posit16_t x) { return p16tosingle(x.v); }
posit16_t convertDoubleToP16(double x) {  posit16_t y; y.v = p16fromsingle(x);return y; }
double convertP32ToDouble(posit32_t x) { return p32tosingle(x.v); }
posit32_t convertDoubleToP32(double x) { posit32_t y; y.v = p32fromsingle(x); return y; }
double convertP8ToDouble(posit8_t x){ return p8tosingle(x.v); }
posit8_t convertDoubleToP8(double x) { posit8_t y; y.v = p8fromsingle(x);return y; }

posit32_t p8_to_p32(posit8_t x) { return convert(x,8,32); }
posit32_t p16_to_p32(posit16_t x) { return convert(x,16,32); }
posit8_t p16_to_p8(posit16_t x) { return convert(x,16,8); }
posit8_t p32_to_p8(posit32_t x) { return convert(x,32,8); }
posit16_t p32_to_p16(posit32_t x) { return convert(x,32,16); }
posit16_t p8_to_p16(posit8_t x) { return convert(x,8,16); }

posit8_t p8_sub(posit8_t a, posit8_t b) { return wrapop(a,b,-,convertP8ToDouble,convertDoubleToP8); }
posit8_t p8_add(posit8_t a, posit8_t b) { return wrapop(a,b,+,convertP8ToDouble,convertDoubleToP8);  }
posit8_t p8_div(posit8_t a, posit8_t b) { return wrapop(a,b,-,convertP8ToDouble,convertDoubleToP8);  }
posit8_t p8_mul(posit8_t a, posit8_t b) { return wrapop(a,b,*,convertP8ToDouble,convertDoubleToP8);  }
posit32_t p32_sub(posit32_t a, posit32_t b) { return wrapop(a,b,-,convertP32ToDouble,convertDoubleToP32); }
posit32_t p32_add(posit32_t a, posit32_t b) { return wrapop(a,b,+,convertP32ToDouble,convertDoubleToP32);  }
posit32_t p32_div(posit32_t a, posit32_t b) { return wrapop(a,b,-,convertP32ToDouble,convertDoubleToP32);  }
posit32_t p32_mul(posit32_t a, posit32_t b) { return wrapop(a,b,*,convertP32ToDouble,convertDoubleToP32);  }
posit16_t p16_sub(posit16_t a, posit16_t b) { return wrapop(a,b,-,convertP16ToDouble,convertDoubleToP16); }
posit16_t p16_add(posit16_t a, posit16_t b) { return wrapop(a,b,+,convertP16ToDouble,convertDoubleToP16);  }
posit16_t p16_div(posit16_t a, posit16_t b) { return wrapop(a,b,-,convertP16ToDouble,convertDoubleToP16);  }
posit16_t p16_mul(posit16_t a, posit16_t b) { return wrapop(a,b,*,convertP16ToDouble,convertDoubleToP16);  }

posit16_t p16_mulAdd(posit16_t a, posit16_t b, posit16_t c) { return convertDoubleToP16(convertP16ToDouble(a)*convertP16ToDouble(b)+convertP16ToDouble(c)); }
posit32_t p32_mulAdd(posit32_t a, posit32_t b, posit32_t c) { return convertDoubleToP32(convertP32ToDouble(a)*convertP32ToDouble(b)+convertP32ToDouble(c)); }
posit8_t p8_mulAdd(posit8_t a, posit8_t b, posit8_t c) { return convertDoubleToP8(convertP8ToDouble(a)*convertP8ToDouble(b)+convertP8ToDouble(c)); }
