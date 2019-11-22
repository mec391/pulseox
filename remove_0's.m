

/////remove zeros

counter = 0;
c = 1;
for c = 1:1048577
if sclk(c,1) == 1
counter = counter + 1;
miso1(counter, 1) = miso(c,1);
mosi1(counter, 1) = mosi(c,1);
else
counter = counter;
miso1(counter, 1) = miso1(counter, 1);
mosi1(counter, 1) = mosi1(counter, 1);




////extract led1 and led2 values
counter1 = 0;
counter2 = 0;
for j = 1:192:900100
for i = 1:192
    k = i + j - 1;
    if i > 8 & i < 33
        counter1 = counter1 +1;
        led1(counter1,1) = miso1(k, 1);
    elseif i > 72 & i < 97
        counter2 = counter2 + 1;
        led2(counter2,1) = miso1(k, 1);
    else
        counter1 = counter1;
        counter2 = counter2;
        
   
        
/////convert binary values to decimal values .. note that
///this is not taking into consideration two's comp so any value with 1 as msb (<0) with not translate correctly
counter5 = 0;
counter3 = 0;
counter4 = 0;
buffer1 = zeros(24, 1);
buffer2 = zeros(24, 1);
led1d = zeros(5000, 1);
led2d = zeros(5000, 1);
for j = 1:24:120000
    counter3 = 0;
    counter4 = 0;
    for i = 1:24
        k = i + j - 1;
        counter3 = counter3 + 1;
        counter4 = counter4 + 1;
        buffer1(counter3, 1) = led1(k,1);
        buffer2(counter4, 1) = led2(k,1);
    end
    counter5 = counter5 + 1;
    led1d(counter5, 1) = polyval(buffer1,2);
    led2d(counter5, 1) = polyval(buffer2, 2);
    
    
  ///convert decimal to voltage
  led1v = zeros(5000,1);
  led2v = zeros(5000,1);
  
  for j = 1:5000
      led1v(j, 1) = ((led1d(j,1) * 1.2) / 2^21);
      led2v(j, 1) = led2d(j,1) * 1.2 / 2^21;
  
      ///generate time as x axis
      xtime = zeros(5000, 1);
      xtime(1,1) = 0;
      for j= 2:5000
          xtime(j,1) = xtime(j-1,1) + 2*10^-3;
          
    ///do fft
    P2 = abs(redfft/4688);
P1 = P2(1:4688/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = 500*(0:(4688/2))/4688;
plot(f, P1)
plot(f, P1)
xlim([0 10])