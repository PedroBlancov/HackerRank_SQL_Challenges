import math
import os
import random
import re
import sys



if __name__ == '__main__':
    n = int(input().strip())

def task():
    if n%2==1:
        print ("Weird")
    elif n%2==0 and (n>=2 or n<=5):
        print ("Not Weird")
    elif n%2==0 and (n>=6 or n<=20):
        print ("Weird")
    elif n%2==0 and (n>20):
        print ("Not Weird")
    
result= task()