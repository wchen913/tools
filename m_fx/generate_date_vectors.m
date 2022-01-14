function date_vectors=generate_date_vectors(date_start,date_end,dt)
% generate date vectors
% input
% date_start - start date
% date_end - end date
% dt - time steps
% output
% date_vectors - dimentions=2,dimention 2 =6;
% e.g. generate_date_vectors([2000 1 1 0 0 0],[2000 12 31 23 59 0],1/48)

addpath('/homes/metofac/wchen/tools/m_fx','-end')

t_start = datenum(date_start);
t_end   = datenum(date_end);
Times   = t_start:dt:t_end;

date_vectors = datevec(Times);

end