clear, clc


for k = 1:255 
    S=k;
    INT = 15; 
    FRA = 10; 
    run_len = 5; 
    x_col = zeros(1, run_len);
    
    %LUT
    if (S<32)
        x_col(1) = 5; 
    elseif(S<81) 
        x_col(1) = 9; 
    else 
        x_col(1) = 16;
    end
    
    for i = 2:run_len
        pre_calc = double(fi(x_col(i-1),0, INT, FRA));
        div_calc = double(fi((S*2^FRA/(pre_calc*2^FRA)),0,INT, FRA)); 
        x_col(i)= 0.5*(pre_calc+div_calc);
        x_col(i)=double(fi(x_col(i),0,INT,FRA));
    end
    actual_sqrt = sqrt(S)*ones(1,run_len); 
    err_iter(: ,k) = (actual_sqrt-x_col); 
end

surf(err_iter); 
max(abs(err_iter(1 ,:)))
max(abs(err_iter(2 ,:)))
max(abs(err_iter(3 ,:)))
max(abs(err_iter(4 ,:)))
max(abs(err_iter(5 ,:)))
        
    