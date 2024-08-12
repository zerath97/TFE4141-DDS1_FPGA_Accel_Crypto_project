"""
This is an implementation of the Montgomery algorithm for modular exponentiation. The algorithm used is described in the "High speed RSA implementation", from the course support literature.
"""


def inverseModulo(a, n):
    """
    Takes two integers `a` and `n` and returns `b` such that it is the inverse of a modulo n.
    """
    b0, b1 = 0, 1  #Starting values for the return value
    r0, r1 = n, a  #Starting values for the current and next remainder
    
    while r1 != 0:
        q = r0 // r1
        b0, b1 = b1, b0 - q * b1
        r0, r1 = r1, r0 - q * r1
        
    if b0 < 0:
        b0 += n
    return b0

def montgomeryProduct(a, b, n, n_complement, r):
    """
    Performs the Montgomery product of two integers `a` and `b` modulo `n`, using the precomputed values `n_complement` and `r`.
    """
          
    product_ab = a * b
    m = (product_ab * n_complement) % r
    u = (product_ab + m * n) // r
    
    if u >= n:
        return u - n
    else:
        return u

"""
This function takes three integers `m`, `e` and `n` and returns `m^e mod n` using the Montgomery algorithm.
Note: the exponent should be coprime to the euler totient of n.
"""
def montgomeryEncryptionDecryption(m, e, n):
    
    e_binary = "{0:b}".format(e)
    n_binary = "{0:b}".format(n)
    
	#nob = number of bits
    e_nob, n_nob = len(e_binary), len(n_binary)
    
    r = 2 ** n_nob
    
    r_inverse = inverseModulo(r, n)
    
    n_complement = (r * r_inverse - 1) // n
    
    m_residue, x_residue = (m * r) % n, r % n
    
    for i in range(0, e_nob):
        x_residue = montgomeryProduct(x_residue, x_residue, n, n_complement, r)
        if int(e_binary[i]) == 1:
            x_residue = montgomeryProduct(m_residue, x_residue, n, n_complement, r)
    
    result = montgomeryProduct(x_residue, 1, n, n_complement, r)
    
    return result


# Running tests
base = 1123456789 #7
exponent = 1579111 #10
modulus = 19 #13
result = montgomeryEncryptionDecryption(base, exponent, modulus)
print(result)
# End of tests