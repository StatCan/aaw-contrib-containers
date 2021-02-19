import argparse

#Fibonacci index starts at 0
fibonacciDict = dict()
fibonacciDict[0] = 0
fibonacciDict[1] = 1

def parse_args():
    parser = argparse.ArgumentParser(
        description='Returns the sum of fibonacci numbers from integer inputs')
    parser.add_argument("numbers", type=int, nargs="+", help="Enter One or more integers")
    parser.add_argument("--output_file", type=str, default="out.txt", help="Filename "
                        "to write output number to")
    return parser.parse_args()
	
def fib_to(n):
    if(n in fibonacciDict):
        return fibonacciDict[n]
    else:
        fibonacciDict[n] = fibonacci(n)
        return fibonacciDict[n]

def fibonacci(n):
    a = 0
    b = 1
     
    # Check is n is less
    # than 0
    if n < 0:
        print("Incorrect input")
    else:
        for i in range(1, n):
            c = a + b
            a = b
            b = c
        return b
        
        
if __name__ == '__main__':
    arg = parse_args()
    numbers = arg.numbers
    output_file = arg.output_file

    fnumlist = []
    
    print(f"Enter positive integers: {numbers}")
    
    for num in numbers:
        fnumlist.append(fib_to(num))

    print(f"Writing output to {output_file}")
    with open(output_file, 'w') as fout:
        print(fnumlist)
        fib_sum = sum(fnumlist)
        print(fib_sum)
        fout.write(str(fib_sum))