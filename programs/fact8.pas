Var n, result;
Begin
    n = 8;
    result = 1;
    REPEAT
        result = result * n;
        n = n - 1;
    UNTIL n == 1
End.