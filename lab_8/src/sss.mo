model sss
Real N = 1, R = 1, K = 5.3, C = 1;
Real W(start=0.1), Q(start=1);
equation
 der(W) = 1/R - W*delay(W, 1)*K*delay(Q, 1)/(2*R);
 if Q > 0 then
 der(Q) = N*W/R - C;
 else
 der(Q) = max(N*W/R - C, 0);
 end if;
end sss;
