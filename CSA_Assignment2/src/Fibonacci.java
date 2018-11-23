public class Fibonacci {

    public static void main(String[] args) {
        Fibonacci f = new Fibonacci();
        int n = 4;
        int[] memo = new int[n+1];
        System.out.println("The Fibonacci numbers are:");
        for (int i=0; i<n; i++)
            System.out.println(i + ": " + f.fib(i, memo));
    }

    public int fib(int n, int[] memo) {
        if (n <= 0)
            return 0;
        else if (n == 1)
            return 1;
        else if (memo[n] > 0)
            return memo[n];

        memo[n] = fib(n-1, memo) + fib(n-2, memo);

        return memo[n];
    }

}
