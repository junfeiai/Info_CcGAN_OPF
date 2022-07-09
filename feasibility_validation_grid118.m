filename = 'case118';
mpc = loadcase(filename);
%aa=runpf(mpc);
p_supply= csvread('p_supply.csv');
vm_gen = csvread('solutionv_list.csv');
pq_demand= csvread('demand_list.csv');
line_constraint = csvread('ROSCUC_118.csv');
mpc.branch(:,6) = line_constraint(:,5);
p_supply = p_supply(:,2:55);
p_demand=pq_demand(:,2:119);
q_demand=pq_demand(:,120:237);
demand_mat_size = size(p_demand);
supply_mat_size = size(p_supply);
sample_size = demand_mat_size(1)-1;
bus_number = demand_mat_size(2);
gen_number = supply_mat_size(2);
success_number = 0;
datapoints_list=[];
conditions_list=[];
for i=1:1000
    p_demand_i = p_demand(i+1,:);
    q_demand_i = q_demand(i+1,:);
    p_supply_i = p_supply(i+1,:);
    vm_gen_i = vm_gen(i+1,:);
    mpc.bus(:,3) = p_demand_i(1:bus_number)*100;
    mpc.bus(:,4) = q_demand_i(1:bus_number)*100;
    mpc.gen(:,2) = p_supply_i(1:gen_number)*100;
    mpc.gen(1,6) = 1;
     %for j=2:gen_number+1
      %  if p_supply_i(j)>0
    mpc.gen(2:gen_number,6) = vm_gen_i(2:gen_number);
    try 
        [result,success]=runpf(mpc,mpoption('pf.enforce_q_lims', 1));
    catch
        
    end
        
    if success==1 && all(result.gen(:,3)<=result.gen(:,4)) && all(result.gen(:,3)>=result.gen(:,5))
        success_number=success_number+1;
    end
end    
