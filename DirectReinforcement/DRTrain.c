/*-------------------------------------------*/
/* DRTrain.c                                 */
/* compile with: mex DRTrain.c               */
/*-------------------------------------------*/
#include <mex.h>
#include <math.h>

/* Arguments */
#define	PRICE_IN        (prhs[0])
#define	PARAMETERS_IN   (prhs[1])
#define WEIGHTS_IN      (prhs[2])
#define EPSILON_IN      (prhs[3])
#define	WEIGHTS_OUT     (plhs[0]) 

// #define DEBUG
#ifdef DEBUG
#define TRACE(...)          mexPrintf(__VA_ARGS__);
#define TRACE_TO_FILE(...)  fprintf(__VA_ARGS__);
#else
#define TRACE(...)          
#define TRACE_TO_FILE(...)
#endif

//#define SIGN(X)         ((X > 0) ? 1.0 : ((X < 0) ? -1.0 : 0))

/* Declerarions */
void parseParameters(double *p);
void printParameters(void);
void parseWeights(double *p);
void printWeights(void);
void setWeights(void);
double sign(double f);
double threeState(double f, double th);
void initArray(double * A, int array_len, double v);
void trainWeights(void);

/* Global Parameters */
double Mu, Delta, Eta, three_state_th, Ni, Rho1, Rho2, Rho3, lambda_rate;
int epochs, train_len, inputs;
double *r;                  // prices
double *v, *u, *w;          // weights (in)
double *epsilon;            // stochastic noise (in)
double *weights;            // weights (out)

/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    size_t m,n;

    //---- Sanity -------------------------------------------------------//
    
    // check for the proper number of inputs and outputs
    if (nrhs != 4)
    {
        mexErrMsgTxt("Expecting four arguments: r, parameters, weights, epsilon.");
    }
    
    if (nlhs > 1)  
    {
        mexErrMsgTxt("Too many output arguments.");
    }
    
    // check for dimentions
    m = mxGetM(PRICE_IN);
    n = mxGetN(PRICE_IN);
    if (!mxIsDouble(PRICE_IN) || mxIsComplex(PRICE_IN) || (n != 1)) 
    { 
	    mexErrMsgTxt("r must be a [nx1] vector."); 
    }
    train_len = (int)m;
    
    m = mxGetM(PARAMETERS_IN);
    n = mxGetN(PARAMETERS_IN);
    if ( (!mxIsDouble(PARAMETERS_IN)) || (m != 1) || (n != 10) )
    {
        mexErrMsgTxt("Parameters should be a [1x10] vector");
    }
    
    m = mxGetM(WEIGHTS_IN);
    n = mxGetN(WEIGHTS_IN);
    if ( (!mxIsDouble(WEIGHTS_IN)) || (m < 2) || (n != 1) )
    {
        mexErrMsgTxt("Weights should be a [(inputs+2)x1] vector");
    }
    inputs = (int)(m-2);
    
    m = mxGetM(EPSILON_IN);
    n = mxGetN(EPSILON_IN);
    epochs  = (int)*(mxGetPr(PARAMETERS_IN)+8);
    if ( (!mxIsDouble(EPSILON_IN)) || (m < train_len*epochs) || (n != 1) )
    {
        mexErrMsgTxt("Epsilon should be a [(train_len*epochs)x1] vector");
    }
    //-------------------------------------------------------------------//
    
    //----- Import Arguments --------------------------------------------//
    r = mxGetPr(PRICE_IN);
//     mexPrintf(">> price vector: r[%dx1]\n",(int)train_len);

    parseParameters((double*)mxGetPr(PARAMETERS_IN));
//     printParameters();
    
    v = (double*)mxMalloc(sizeof(double)*inputs);
    u = (double*)mxMalloc(sizeof(double));
    w = (double*)mxMalloc(sizeof(double));
    
    parseWeights((double*)mxGetPr(WEIGHTS_IN));
//     printWeights();

    epsilon = mxGetPr(EPSILON_IN);
    
    // Create a matrix for the return argument, assign pointer
    WEIGHTS_OUT = mxCreateDoubleMatrix( (mwSize)(inputs+2), (mwSize)1, mxREAL); 
    weights = mxGetPr(WEIGHTS_OUT);

    //-------------------------------------------------------------------//
    
    //----- Running Computational Routine -------------------------------//
//     mexPrintf(">> Starting DRTrain.c...\n");
    TRACE("*** DRTrain.c in Debug Mode ***\n");
    trainWeights();
//     mexPrintf(">> done.\n");
    //-------------------------------------------------------------------//
    
    mxFree(v);
    mxFree(u);
    mxFree(w);
}

void parseParameters(double *p)
{
    Mu      = *(p+0);
    Delta   = *(p+1);
    Eta     = *(p+2);
    three_state_th = *(p+3);
    Ni      = *(p+4);
    Rho1    = *(p+5);
    Rho2    = *(p+6);
    Rho3    = *(p+7);
    lambda_rate = *(p+8);
    epochs  = (int)*(p+9);
}

void printParameters(void)
{
    mexPrintf(">> Parameters:\n");
    mexPrintf("   - Mu = %f\n",Mu);
    mexPrintf("   - Delta = %f\n",Delta);
    mexPrintf("   - Eta = %f\n",Eta);
    mexPrintf("   - Ni = %f\n",Ni);
    mexPrintf("   - Rho = %f, %f, %f\n",Rho1,Rho2,Rho3);
    mexPrintf("   - Lambda rate = %f\n",lambda_rate);
    mexPrintf("   - epochs = %d\n",epochs);
    mexPrintf("   - train length = %d\n",train_len);
    mexPrintf("   - inputs = %d\n",inputs);
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
}

void setWeights(void)
{
    int i;   
    for (i=0; i<inputs; i++)
    {
        *(weights+i) = *(v+i);
    }
    *(weights+inputs+0) = *u;
    *(weights+inputs+1) = *w;
}

// Dot Product of weights and price(t) //
double dotProduct(int t)
{
    int i;
    double dp=0;
    
    for(i=0; i<inputs; i++)
    {
        dp += (*(v+i)) * (*(r+t-inputs+i)); 
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
/* Train Weights Function                                                */
/*-----------------------------------------------------------------------*/
void trainWeights(void)
{
    double *F_ut, *F, *R; // F is unthresholded
    double  *A, *B; 
    double *L, *M, *O;
    double **N;
    int i, epoch, t;
    double wr, den, lambda = 1;
    double dA, dB, ds, dw, du, dv;

#ifdef DEBUG    
    FILE *fp, *wfp;
#endif

    /*---- Initialization ----------------------------------*/
    F_ut  = (double*)mxMalloc(sizeof(double)*train_len);
    F  = (double*)mxMalloc(sizeof(double)*train_len);
    R  = (double*)mxMalloc(sizeof(double)*train_len);
    A  = (double*)mxMalloc(sizeof(double)*train_len);
    B  = (double*)mxMalloc(sizeof(double)*train_len);
    L  = (double*)mxMalloc(sizeof(double)*train_len);
    M  = (double*)mxMalloc(sizeof(double)*train_len);
    O  = (double*)mxMalloc(sizeof(double)*train_len);
    
    N = (double**)mxMalloc(sizeof(double*)*(inputs+2));
    for(i=0; i<(inputs+2); i++)
    {
        N[i] = (double*)mxMalloc(sizeof(double)*train_len);
        initArray(N[i],train_len,0);
    }
    
    initArray(F_ut,train_len,0);
    initArray(F,train_len,0);
    initArray(A,train_len,0);
    initArray(B,train_len,1);
    /*------------------------------------------------------*/
    
#ifdef DEBUG
    fp = fopen("Trace_DRTrain.txt","w");
    wfp = fopen("Weights_DRTRain.txt","w");
#endif        
    
    TRACE_TO_FILE(fp,"---Trace START---\n");
    TRACE_TO_FILE(fp,"[-t-]\t--r(t)--\t--F_ut--\t---F----\t---R----\t---A----\t---B----\t---L----\t---M----\t---O----\t");
    for(i=0; i<(inputs+2); i++)
    {
        TRACE_TO_FILE(fp,"---N%d---\t",i);    
    }
    TRACE_TO_FILE(fp,"\n");
    
    /*---- Weight Train ------------------------------------*/
    for(epoch=0; epoch<epochs; epoch++)
    {
        for(t=inputs; t<train_len; t++)
        {
            wr = dotProduct(t);
            F_ut[t] = tanh( u[0] * F_ut[t-1] + wr + w[0] + epsilon[t+epoch*train_len]*lambda ); 
            
            if (three_state_th > 0 )
                F[t] = threeState(F_ut[t], three_state_th);
            else
                F[t] = sign(F_ut[t]);
            
            lambda *= lambda_rate;
            
            R[t] = Mu * ( F[t-1]*(r[t]) - Delta*fabs(F[t] - F[t-1]) );
            
            dA = R[t] - A[t-1];
            dB = R[t]*R[t] - B[t-1];
            A[t] = A[t-1] + Eta*dA;
            B[t] = B[t-1] + Eta*dB;
            
            ds = sign(F_ut[t]-F_ut[t-1]);
            
            den = (B[t-1]-A[t-1]*A[t-1]);
            if( den!=0 )
            {
                L[t] = (B[t-1]-A[t-1]*R[t]) / pow(den,1.5);
            }
            
            M[t] = -Mu*Delta*ds;
            O[t] = Mu*(r[t]) + Mu*Delta*ds;
            
            TRACE_TO_FILE(fp,"[%d]\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t",t,r[t],F_ut[t],F[t],R[t],A[t],B[t],L[t],M[t],O[t]);
            TRACE_TO_FILE(wfp,"[%d]\t",t);

            // calculate dv for all v(i)
            for (i=0; i<inputs; i++)
            {
                N[i][t] = (1-F_ut[t]*F_ut[t])*( u[0] * N[i][t-1] + r[t-inputs+i] );
                dv = Rho1*L[t]*(M[t]*N[i][t] + O[t]*N[i][t-1]);
                v[i] = v[i] * (1-Ni) + dv;
                
                TRACE_TO_FILE(fp,"%f\t",N[i][t]);
                TRACE_TO_FILE(wfp,"%f\t",v[i]);
            }
            
            // calculate du - coefficient of F[t-1]
            i = inputs;
            N[i][t] = (1-F_ut[t]*F_ut[t])*( u[0] * N[i][t-1] + F_ut[t] ); // should be F_ut[t-1], no?
            du = Rho2*L[t]*(M[t]*N[i][t] + O[t]*N[i][t-1]);
            u[0] = u[0] * (1-Ni) + du;
            
            TRACE_TO_FILE(fp,"%f\t",N[i][t]);
            TRACE_TO_FILE(wfp,"%f\t",u[0]);
            
            // calculate dw - bias
            i = inputs+1;
            N[i][t] = (1-F_ut[t]*F_ut[t])*( u[0] * N[i][t-1] + 1 );
            dw = Rho3*L[t]*(M[t]*N[i][t] + O[t]*N[i][t-1]);
            w[0] = w[0] * (1-Ni) + dw;
            
            TRACE_TO_FILE(fp,"%f\t\n",N[i][t]);
            TRACE_TO_FILE(wfp,"%f\t\n",w[0]);
        }
        
    }
    /*------------------------------------------------------*/
   
    TRACE_TO_FILE(fp,"---Trace END---");
#ifdef DEBUG    
    fclose(fp);
    fclose(wfp);
#endif
    
    // apply weights to return value
    setWeights();
    
    mxFree(F);
    mxFree(R);
    mxFree(A);
    mxFree(B);
    mxFree(L);
    mxFree(M);
    mxFree(O);
    mxFree(N);
}

