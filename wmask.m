% Draw the world landmask
function wmask(coastline,landcolor)

 cc=load(coastline);

[l_line,~]=find(isnan(cc));

l_line=[0;l_line];

mat1=size(l_line);
n_l_line=mat1(1,1);

for ii=1:n_l_line-1;
    ns_line=l_line(ii)+1;
    ne_line=l_line(ii+1)-1;
    if (ne_line-ns_line)>10
        lo=cc(ns_line:ne_line,1);
        la=cc(ns_line:ne_line,2);
        fill(lo,la,landcolor);
        hold on
    end

end


