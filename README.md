# Readme

## Setuup
1. git clone Project  
2. cd Sisyphus
3. set up project env `source script/project.cshrc`
4. `cd verification/toptest/sim` to go into sim 
5. `make cmp`: compile
6. `make run tc=tc_sanity seed=1 wave=on ccov=off fcov=off printlv=UVM_HIGH mode=sim_test`: compile and simulation 
7. `make verdi`: open verdi
8. `make cov`: open verdi for checking coverage

## Regression
`python3 script/regression.py --list script/regress_list.json` : run regression
