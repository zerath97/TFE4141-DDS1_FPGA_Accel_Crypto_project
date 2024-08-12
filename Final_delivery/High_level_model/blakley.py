import math

# Solving R = (a*b) mod n, using Blakley's algorithm.
def blakley(a, b, n):
    print("a: " + hex(a))
    print("b: " + hex(b))
    k = max(a.bit_length(), b.bit_length())
    k= 256
    R = 0
    maxR = 0
    for bit_i in range(k):
        print("R: " + hex(R))
        print("Doubling R") 
        R = 2 * R  # Double R
        if R > maxR:
           maxR = R
        
        if (a >> (k - 1 - bit_i)) & 1:
            print('adding B')
            R = R + b  
        it = 0
        # Modular reduction (added while-loop to prevent R from growing too large)
        if R >= n:
            R -= n
            it += 1
        if R >= n:
            R -= n
            it += 1
        print ("Number of reductions: " + str(it) + " Final R: " + hex(R))
        #if it > 1:
            #print("Number of reductions: " + str(it))
			
    print("R: " + hex(R))
    print("Max R bits: " + str(maxR.bit_length()))
    return R


# Modular multiplication using the left-to-right (LR) Binary Method.
def binarymethod(M, e, n):
    C = 1  # Initialize C to 1
    it = 0
    for bit_i in range(e.bit_length() - 1, -1, -1):
        it += 1
        
        print("ITERATION #: " + str(it))
        print('P Black')
        print(hex(C))
        C = blakley(C, C, n) # P Blackley
        if (e >> bit_i) & 1:
            print('C Black')
            C = blakley(C, M, n)  # C Blackley

    return C

# Running test:
M = 0x0000000011111111222222223333333344444444555555556666666677777777
e = 0x0000000000000000000000000000000000000000000000000000000000010001
n = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
result = binarymethod(M, e, n)
print(hex(result))
print(hex(M**e % n))
