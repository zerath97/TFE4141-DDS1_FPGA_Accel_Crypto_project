import math

# Solving R = (a*b) mod n, using Blakley's algorithm.
def blakley(a, b, n):
    k = max(a.bit_length(), b.bit_length())

    R = 0
    for bit_i in range(k):
        R = 2 * R  # Double R
        if (a >> (k - 1 - bit_i)) & 1:
            R = R + b  

        # Modular reduction (added while-loop to prevent R from growing too large)
        while R >= n:
            R -= n

    return R


# Modular multiplication using the left-to-right (LR) Binary Method.
def binarymethod(M, e, n):
    C = 1  # Initialize C to 1

    for bit_i in range(e.bit_length() - 1, -1, -1):
        C = blakley(C, C, n)  
        if (e >> bit_i) & 1:
            C = blakley(C, M, n) 

    return C

# Test with provided values
M = 4585210641520563191941344918006406890329395072927096477359035763793741423395
e = 65537
n = 69462387664806101508579269628495904991077111001183212100694836457047689492109

result = binarymethod(M, e, n)
print("From python math:", (M**e)%n)
print("From high level code:", result)
print("Correct value copied from text file:", 60578906216160987903614231660022457258074710702519959909272518773328503704577)
