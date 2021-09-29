model sss
Real a = 2, b = 1, c = 0.3, d = 1;
Real x(start=2.0), y(start=1);
equation
 der(x) = a*x - b*x*y;
 der(y) = c*x*y - d*y;
end sss;
