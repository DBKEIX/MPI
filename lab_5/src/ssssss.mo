class ssssss
final constant Real b=1;
final constant Real nu=1;
final constant Real mu=1;
final constant Real n=1;
Real s(start=0.999), i(start=0.00), r(start=0.0);
equation
der (s)=-b*s*i+mu*(n-s);
der (i)=b*s*i-nu*i-mu*i;
der (r)=nu*i-mu*r;
end ssssss;
