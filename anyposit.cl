/**
 STATUS: 
 - fromsingle not impl
 - pass fixed and singl typ
 */
#define CONCAT(a, b) a##b
#define XCONCAT(a, b) CONCAT(a, b)
#define POSIT_STYPEV(n) XCONCAT(POSIT_STYPE,n)
#define POSIT_UTYPEV(n) XCONCAT(POSIT_UTYPE,n)
#define bitand(a,b) ((a) & (b))
#define bitxor(a,b) ((a) ^ (b))
#define bitor(a,b) ((a) | (b))
#define bitcmp(a)  (~(a))
#define bit_srl(a,k)  ((POSIT_STYPE)(((POSIT_UTYPE)a)>>(k)))
#define bit_sll(a,k) ((a) << (k))
#define bit_sra(a,k) ((a) >> (k))
#define bit_01_0all(x) ((x) == 0 ? 0 : -1)
#define bit_neg(x) (-(x))
#define bit_msb(x) bitand(bit_sra(x,(sizeof(x)*8-1)),1)

#define bit_ite(c,a,b) ((c) ? (a):(b))
#define bit_iszero(a) ((a) == 0)
#define asignbits  (sizeof(POSIT_STYPE)*8-POSIT_NBITS+1)
#define bit_changesign(x,c) bit_ite(c, -(x),x)
/*
POSIT_STYPEV(2) bit_abs(POSIT_STYPE X)
{
	return  POSIT_STYPEV(2)(abs(X), X & POSIT_SIGNMASK);
}
*/
int XCONCAT(PREFIX,tosingle)(POSIT_STYPE A);
long XCONCAT(PREFIX,todouble)(POSIT_STYPE A);

POSIT_STYPE XCONCAT(PREFIX,int_log2)(POSIT_STYPE X)
{
	return X == 0 ? 0 : (sizeof(X)*8-1)-clz(X);
}

#if POSIT_ESBITS == 0

// clz(0) = N
// clz(1) = N-1
// clz(sign) = 0

POSIT_STYPE XCONCAT(PREFIX,fasthalf)(POSIT_STYPE X)
{
	POSIT_STYPE x_lt1,x_ge1,Y1 ,x_ge2;
	POSIT_STYPE Xa = abs(X);
	POSIT_STYPE X_invbit = bitand(Xa,POSIT_INVBIT);
	POSIT_STYPE Xs = Xa << 1;
	POSIT_STYPE Xs_invbit = bitand(Xs,POSIT_INVBIT);

	x_lt1 = Xs >> 1; // arithmetic, carries the invbit down
	x_ge2 = Xs << 1; 
	x_ge1 = bit_ite(bit_iszero(Xs_invbit),bitxor(Xs,POSIT_TWICEMASK),x_ge2);
	Y1 = bit_ite(bit_iszero(X_invbit),x_lt1,x_ge1);
	Y1 = bit_srl(Y1,1); // logical
	return X < 0 ? -Y1 : Y1;  // reapply sign
}

POSIT_STYPE XCONCAT(PREFIX,fasttwice)(POSIT_STYPE X)
{
	POSIT_STYPE x_lt1,x_ge1,Y1,x_lthalf;
	POSIT_STYPE Xa = abs(X);
	POSIT_STYPE X_invbit = bitand(Xa,POSIT_INVBIT);
	POSIT_STYPE Xs = Xa << 1;
	POSIT_STYPE Xs_invbit = bitand(Xs,POSIT_INVBIT);

	x_ge1 = Xs >> 1; // arithmetic, carries the invbit down
	x_lthalf = Xs << 1;
	x_lt1 = bit_ite(bit_iszero(Xs_invbit),x_lthalf,bitxor(Xs,POSIT_TWICEMASK));
	Y1 = bit_ite(bit_iszero(X_invbit),x_lt1,x_ge1);
	Y1 = bit_srl(Y1,1); // logical
	return X < 0 ? -Y1 : Y1;  // reapply sign
}

POSIT_STYPE XCONCAT(PREFIX,fastsigmoid)(POSIT_STYPE A)
{
    POSIT_NSTYPE a = (POSIT_NSTYPE)A;
    POSIT_NSTYPE iv = (((POSIT_NSTYPE)POSIT_INVBIT) << 1)+1;
    return (POSIT_STYPE)((a+iv) >> 2);		
}

POSIT_STYPE XCONCAT(PREFIX,fasthalfcomp)(POSIT_STYPE A)
{
	 return (POSIT_INVBIT >> 1)-A;
}

POSIT_STYPE XCONCAT(PREFIX,fastreciprocate)(POSIT_STYPE A) 
{
	return bitxor(A,(POSIT_STYPE)~(POSIT_UTYPE)POSIT_SIGNMASK); // 
}

#ifdef __OPENCL_VERSION__

kernel void XCONCAT(pk_fasthalf)(const global POSIT_STYPE *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = XCONCAT(PREFIX,fasthalf)(A[id]);
};

kernel void XCONCAT(pk_fasttwice)(const global POSIT_STYPE *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = XCONCAT(PREFIX,fasttwice)(A[id]);
};

kernel void XCONCAT(pk_abs)(const global POSIT_STYPE *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = abs(A[id]);
};

kernel void XCONCAT(pk_fastsigmoid)(const global POSIT_STYPE *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = XCONCAT(PREFIX,fastsigmoid)(A[id]);
};

kernel void XCONCAT(pk_fastreciprocate)(const global POSIT_STYPE *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = XCONCAT(PREFIX,fastreciprocate)(A[id]);
}

kernel void XCONCAT(pk_tanh)(const global POSIT_STYPE *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = -XCONCAT(PREFIX,fasttwice)(XCONCAT(PREFIX,fasthalfcomp)(XCONCAT(PREFIX,fastsigmoid)(XCONCAT(PREFIX,fasthalf)(A[id]))));
};
#endif

#endif

POSIT_STYPE XCONCAT(PREFIX,fromsingle)(int X)
{
	int Y,R,rho,o,sP;
	int e = bitand(bit_sra(X,23),(1<<8)-1)-127;
	int m = bit_sll(X,9); 
	int k,es;
	int invbit;
	#if POSIT_ESBITS != 0
		k = bit_sra(e,POSIT_ESBITS);
		es = bit_sll(e-bit_sll(k,POSIT_ESBITS),POSIT_NBITS-POSIT_ESBITS);
	#else
		k = e;
		es = 0;
	#endif
	invbit = e < 0 ? 0 : 1;
	R = (e < 0 ? -k : k)+1;
	sP = POSIT_NBITS-R;
	rho = bitor(bit_01_0all(invbit),1);
	rho = bit_sra(bit_sll(rho,sP),1);
	R = R-1+invbit;
	o = bit_sra(m,32-POSIT_NBITS);

	#if POSIT_ESBITS != 0
		o = bitor(bit_sra(o,POSIT_ESBITS),es);
	#endif
	Y = bitor(bit_sra(o,R+2),rho);
	Y = X < 0 ? -Y : Y;
	return Y;
}

POSIT_STYPE XCONCAT(PREFIX,fromlong)(long X)
{
	int Y,R,rho,o,sP;
	int e = bitand(bit_sra(X,52),(1<<11)-1)-1023;
	int m = bit_sll(X,9); 
	int k,es;
	int invbit;
	#if POSIT_ESBITS != 0
		k = bit_sra(e,POSIT_ESBITS);
		es = bit_sll(e-bit_sll(k,POSIT_ESBITS),POSIT_NBITS-POSIT_ESBITS);
	#else
		k = e;
		es = 0;
	#endif
	invbit = e < 0 ? 0 : 1;
	R = (e < 0 ? -k : k)+1;
	sP = POSIT_NBITS-R;
	rho = bitor(bit_01_0all(invbit),1);
	rho = bit_sra(bit_sll(rho,sP),1);
	R = R-1+invbit;
	o = bit_sra(m,64-POSIT_NBITS);

	#if POSIT_ESBITS != 0
		o = bitor(bit_sra(o,POSIT_ESBITS),es);
	#endif
	Y = bitor(bit_sra(o,R+2),rho);
	Y = X < 0 ? -Y : Y;
	return Y;
}
// for NBITS 16 and 8
int XCONCAT(PREFIX,tosingle)(POSIT_STYPE A)
{
	POSIT_STYPE Xs,Xi,invbit,flipmask,Xm,sp,R,Xr,Xe,Xf,X;
	long m,e,k;
	if (A == 0)
		return 0;

	X = abs(A);       
    Xs = bit_sll(X,1);
    Xi = bit_sll(X,asignbits);  // invbit[R] 0 rest
    invbit = bit_msb(Xi); // bit_msb(Xi); % 0 or 1

    flipmask = bit_neg(invbit); // 0 or -1
    Xm = bitxor(Xi,flipmask); // 0[R] 1 rest[N-1-R]

    // ATTENTION: X=0 gives sp=0, whils X=1 gives sp=1
    sp = XCONCAT(PREFIX,int_log2)(Xm); // sp=N-1-R

    R = POSIT_NBITS-sp-1; // if sp=0 R=bits , all the rest becomes ZERO
    Xr = bit_sll(Xs,R+1); // rest[N-1-R] 0[R+1]

    if(POSIT_ESBITS == 0)
    {
    	Xe = 0;
    	Xf = Xr;
	}
	else
	{
	    Xe = bit_sra(Xr,POSIT_NBITS-POSIT_ESBITS); //% only exponent positive
	    Xf = bit_sll(Xr,POSIT_ESBITS); //% fully aligned on left (but only a part needed)		
	}

    k = bit_changesign((int)(R),(int)1-(int)(invbit))-(int)(invbit);

    e = bit_sll(bit_sll((int)(k),POSIT_ESBITS)+(int)(Xe)+(int)(127),23); //% bias

    // fraction is aligned to self.bits and move to 23
    #if POSIT_NBITS >= 23
        // if 32 then shift right
        m = (int)(bit_srl(Xf,(POSIT_NBITS-23));
    #else
    	// or shift left
        m = bit_sll((int)(Xf),23-POSIT_NBITS); 
    #endif
    return (A < 0 ? ((int)1)<<31 : 0)|e|(m & 0x07FFFFF);

}


// for NBITS 16 and 8
int XCONCAT(PREFIX,todouble)(POSIT_STYPE A)
{
	POSIT_STYPE Xs,Xi,invbit,flipmask,Xm,sp,R,Xr,Xe,Xf,X;
	long m,e,k;
	if (A == 0)
		return 0;

	X = abs(A);       
    Xs = bit_sll(X,1);
    Xi = bit_sll(X,asignbits);  // invbit[R] 0 rest
    invbit = bit_msb(Xi); // bit_msb(Xi); % 0 or 1

    flipmask = bit_neg(invbit); // 0 or -1
    Xm = bitxor(Xi,flipmask); // 0[R] 1 rest[N-1-R]

    // ATTENTION: X=0 gives sp=0, whils X=1 gives sp=1
    sp = XCONCAT(PREFIX,int_log2)(Xm); // sp=N-1-R

    R = POSIT_NBITS-sp-1; // if sp=0 R=bits , all the rest becomes ZERO
    Xr = bit_sll(Xs,R+1); // rest[N-1-R] 0[R+1]

    if(POSIT_ESBITS == 0)
    {
    	Xe = 0;
    	Xf = Xr;
	}
	else
	{
	    Xe = bit_sra(Xr,POSIT_NBITS-POSIT_ESBITS); //% only exponent positive
	    Xf = bit_sll(Xr,POSIT_ESBITS); //% fully aligned on left (but only a part needed)		
	}

    k = bit_changesign((int)(R),(int)1-(int)(invbit))-(int)(invbit);

    e = bit_sll(bit_sll((int)(k),POSIT_ESBITS)+(int)(Xe)+(int)(1023),52); //% bias

    // fraction is aligned to self.bits and move to 52
    #if POSIT_NBITS >= 52
        // if 32 then shift right
        m = (int)(bit_srl(Xf,(POSIT_NBITS-52));
    #else
    	// or shift left
        m = bit_sll((int)(Xf),52-POSIT_NBITS); 
    #endif
    return (A < 0 ? ((int)1)<<63 : 0)|e|(m & 0x07FFFFFFFFFFFFF);

}
#ifdef __OPENCL_VERSION__

kernel void XCONCAT(PREFIX,pk_tosingle)(const global POSIT_STYPE *A,global int *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = tosingle(A[id]);
};

kernel void XCONCAT(PREFIX,pk_fromsingle)(const global int *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = fromsingle(A[id]);
};


kernel void XCONCAT(PREFIX,pk_testx)(const global POSIT_STYPE *A,global POSIT_STYPE *B)
{
    const uint id = get_global_id(0); // Row ID of C (0..M)
    B[id] = bit_msb(A[id]);
};

#endif