/*-------------------------------------------*/
/* DRDPass.c                                 */
/* compile with: mex DRDPass.c               */
/* designed for aux series                   */
/*-------------------------------------------*/
#include <mex.h>
#include <math.h>

/* Arguments */
#define	PRICE_IN        (prhs[0])
#define AUX_IN          (prhs[1])
#define	PARAMETERS_IN   (prhs[2])
#define WEIGHTS_IN      (prhs[3])
#define UT_SIGNAL_OUT   (plhs[0])
#define SIGNAL_OUT      (plhs[1])
#define PROFIT_OUT      (plhs[2])
#define SHARPE_OUT      (plhs[3])

#define EXPECTED_ARGUMENTS      (4)
#define EXPECTED_OUTPUTS        (4)
#define PARAMETER_VECTOR_LEN    (11)
#define EPOCH_PARAMETER_OFFSET  (8)

// #define DEBUG
#ifdef DEBUG
#define TRACE(...)          mexPrintf(__VA_ARGS__);
#define TRACE_TO_FILE(...)  fprintf(__VA_ARGS__);
#else
#define TRACE(...)          
#define TRACE_TO_FILE(...)
#endif

/* Declerarions */
void parseParameters(double *p);
void printParameters(void);
void parseWeights(double *p);
void printWeights(void);
double dotProduct(double * wgt, double * ser, int t);
double sign(double f);
double threeState(double f, double th);
void initArray(double * A, int array_len, double v);
void passSeries(void);

/* Global Parameters */
double Mu, Delta, Eta, three_state_th, Zeta;
int series_len, inputs;
double *r, *y;              // prices
double *v, *u, *w, *s;      // weights (in)
double *F_ut, *F, *P, *sharpe;

/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    size_t m,n;

    //---- Sanity -------------------------------------------------------//
    
    // check for the proper number of inputs and outputs
    if (nrhs != EXPECTED_ARGUMENTS)
    {
        mexErrMsgTxt("Expecting four arguments: r, y, parameters, weights.");
    }
    
    if (nlhs != EXPECTED_OUTPUTS)  
    {
        mexErrMsgTxt("Expecting four output arguments: F_ut, F, P, Sharpe");
    }
    
    // check for dimentions
    m = mxGetM(PRICE_IN);
    n = mxGetN(PRICE_IN);
    if (!mxIsDouble(PRICE_IN) || mxIsComplex(PRICE_IN) || (n != 1)) 
    { 
	    mexErrMsgTxt("R(t) must be a [nx1] vector."); 
    }
    series_len = (int)m;
    
    m = mxGetM(AUX_IN);
    n = mxGetN(AUX_IN);
    if (!mxIsDouble(AUX_IN) || mxIsComplex(AUX_IN) || (n != 1) || (m != series_len)) 
    { 
	    mexErrMsgTxt("Y(t) must be a [nx1] vector."); 
    }
    
    m = mxGetM(PARAMETERS_IN);
    n = mxGetN(PARAMETERS_IN);
    if ( (!mxIsDouble(PARAMETERS_IN)) || (m != 1) || (n != PARAMETER_VECTOR_LEN) )
    {
        mexErrMsgTxt("Parameters should be a [1x11] vector");
    }
    
    m = mxGetM(WEIGHTS_IN);
    n = mxGetN(WEIGHTS_IN);
    if ( (!mxIsDouble(WEIGHTS_IN)) || (m < 2) || (n != 1) )
    {
        mexErrMsgTxt("Weights should be a [(2*inputs+2)x1] vector");
    }
    inputs = (int)((m-2)/2);
    //-------------------------------------------------------------------//
    
    //----- Import Arguments --------------------------------------------//
    r = mxGetPr(PRICE_IN);
//     mexPrintf(">> price vector: r[%dx1]\n",(int)train_len);

    y = mxGetPr(AUX_IN);
//     mexPrintf(">> auxilliary vector: y[%dx1]\n",(int)train_len);
    
    parseParameters((double*)mxGetPr(PARAMETERS_IN));
//     printParameters();
    
    v = (double*)mxMalloc(sizeof(double)*inputs);
    u = (double*)mxMalloc(sizeof(double));
    w = (double*)mxMalloc(sizeof(double));
    s = (double*)mxMalloc(sizeof(double)*inputs);
    
    parseWeights((double*)mxGetPr(WEIGHTS_IN));
	//printWeights();

    // Create matrices for the return arguments, assign pointer
    UT_SIGNAL_OUT = mxCreateDoubleMatrix( (mwSize)(series_len), (mwSize)1, mxREAL);
    SIGNAL_OUT    = mxCreateDoubleMatrix( (mwSize)(series_len), (mwSize)1, mxREAL);
    PROFIT_OUT    = mxCreateDoubleMatrix( (mwSize)(series_len), (mwSize)1, mxREAL);
    SHARPE_OUT    = mxCreateDoubleMatrix( (mwSize)(series_len), (mwSize)1, mxREAL);
    F_ut = mxGetPr(UT_SIGNAL_OUT);
    F    = mxGetPr(SIGNAL_OUT);
    P    = mxGetPr(PROFIT_OUT);
    sharpe = mxGetPr(SHARPE_OUT);

    //-------------------------------------------------------------------//
    
    //----- Running Computational Routine -------------------------------//
//     mexPrintf("_>> Starting DRPass.c...\n");
    TRACE("*** DRDPass.c in Debug Mode ***\n");
    passSeries();
//     mexPrintf("_>> done.\n");
    //-------------------------------------------------------------------//
    
    mxFree(v);
    mxFree(u);
    mxFree(w);
    mxFree(s);
}

void parseParameters(double *p)
{
    Mu      = *(p+0);
    Delta   = *(p+1);
    Eta     = *(p+2);
    three_state_th = *(p+3);
    Zeta    = *(p+10);
}

void printParameters(void)
{
    mexPrintf(">> Parameters:\n");
    mexPrintf("   - Mu = %f\n",Mu);
    mexPrintf("   - Delta = %f\n",Delta);
    mexPrintf("   - Eta = %f\n",Eta);
    mexPrintf("   - series length = %d\n",series_len);
    mexPrintf("   - inputs = %d\n",inputs);
    mexPrintf("   - Zeta = %f\n",Zeta);
}

void parseWeights(double *p)
{
    int i;
 
    for (i=0;i<inputs;i++)
    {
        *(v+i) = *(p+i);
    }
    
    *u = *(p+inputs+0);
    *w = *(p+inputs+1);
    
    for (i=0; i<inputs;i++)
    {
        *(s+i) = *(p+inputs+2+i);
    }
}

void printWeights(void)
{
    int i;
    mexPrintf(">> Weights:\n   - v: ");
    for (i=0; i<(inputs-1); i++)
    {
        mexPrintf("%f, ",*(v+i));
    }
    mexPrintf("%f\n",*(v+inputs-1));
    mexPrintf("   - u: %f\n",*u);
    mexPrintf("   - w: %f\n",*w);
    mexPrintf("   - s: ");
    for (i=0; i<(inputs-1); i++)
    {
        mexPrintf("%f, ",*(s+i));
    }
    mexPrintf("%f\n",*(s+inputs-1));        
}

// Dot Product of weights and price(t) //
double dotProduct(double * wgt, double * ser, int t)
{
    int i;
    double dp=0;
    
    for(i=0; i<inputs; i++)
    {
        dp += (*(wgt+i)) * (*(ser+t-inputs+i)); 
    }
    
    return dp;
}

double sign(double f)
{
    if(f>0)
        return 1;
    else if(f<0)
        return -1;
    else
        return 0;
}

double threeState(double f, double th)
{
    if (f > th)
        return 1;
    else if (f < -th)
        return -1;
    return 0;    
}

void initArray(double * A, int array_len, double v)
{
    int i;
    for(i=0; i<array_len; i++)
    {
        *(A+i) = v;
    }
}

/*-----------------------------------------------------------------------*/
/* Run a pass                                                            */
/*-----------------------------------------------------------------------*/
void passSeries(void)
{
    double  *R, *Rs, *A, *B; 
    int i, t;
    double wr, sy, dA, dB;

#ifdef DEBUG    
    FILE *fp, *wfp;
#endif

    /*---- Initialization ----------------------------------*/
    R  = (double*)mxMalloc(sizeof(double)*series_len);
    Rs = (double*)mxMalloc(sizeof(double)*series_len);
    A  = (double*)mxMalloc(sizeof(double)*series_len);
    B  = (double*)mxMalloc(sizeof(double)*series_len);
    
    initArray(F_ut,inputs,0);
    initArray(F,inputs,0);
    initArray(P,inputs,0);
    initArray(sharpe,inputs,0);
    initArray(R,series_len,0);
    initArray(Rs,series_len,0);
    initArray(A,series_len,0);
    initArray(B,series_len,1);
    /*------------------------------------------------------*/
    
#ifdef DEBUG
    fp = fopen("Trace_DRPass.txt","w");
#endif        
    
    TRACE_TO_FILE(fp,"---Trace START---\n");
    TRACE_TO_FILE(fp,"[-t-]\t--r(t)--\t--F_ut--\t---F----\t---R----\t---A----\t---B----\n");
    
    for(t=inputs; t<series_len; t++)
    {
        
        wr = dotProduct(v,r,t);
        sy = dotProduct(s,y,t);
        F_ut[t] = tanh( u[0] * F_ut[t-1] + wr + sy + w[0] ); 
        
        if (three_state_th > 0 )
            F[t] = threeState(F_ut[t], three_state_th);
        else
            F[t] = sign(F_ut[t]);

        R[t] = Mu * ( F[t-1]*(r[t]) - Delta*fabs(F[t] - F[t-1]) );
        P[t] = P[t-1] + R[t];
        Rs[t] = R[t] + Zeta*F[t-1]*y[t];

        dA = Rs[t] - A[t-1];
        dB = Rs[t]*Rs[t] - B[t-1];
        A[t] = A[t-1] + Eta*dA;
        B[t] = B[t-1] + Eta*dB;
        sharpe[t] = A[t]/B[t];

        TRACE_TO_FILE(fp,"[%d]\t%f\t%f\t%f\t%f\t%f\t%f\t",t,r[t],F_ut[t],F[t],R[t],A[t],B[t]);
       
    }
    /*------------------------------------------------------*/
   
    TRACE_TO_FILE(fp,"---Trace END---");
#ifdef DEBUG    
    fclose(fp);
#endif
    
    mxFree(R);
    mxFree(Rs);
    mxFree(A);
    mxFree(B);
}