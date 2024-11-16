import subprocess as subps
import re
import json
import argparse
import random
import datetime

log_file = "reg_" + datetime.datetime.now().strftime('%Y%m%d_%H%M%S') + ".log"

parser = argparse.ArgumentParser()
parser.add_argument('--list', dest='regr_list_path', type=str)
args = parser.parse_args()

#Open Json File
f = open(args.regr_list_path) 
reglist = json.load(f)
f.close()

#Get Mode and compile 
reg_mode = reglist.pop(0)['mode']
cmpout = subps.getstatusoutput(f'make cmp mode={reg_mode}')

#Check any compile error
for line in cmpout:
    if(type(line) == str):
        if(re.search("Error", line)):
            print("Compile Error!!!!")
            print("Exit Regression")
            exit()

print("Success Compile!!!!")
print("Start Regression!!!!")

pass_num = 0;
fail_num = 0;
invalid_num = 0;
total_num = 0;
finish_num = 0;

for tc in reglist:
   total_num += tc['num'] 
print("Total TC Number: " + str(total_num))

fail_case_list = []

for i in range(total_num): 
    #print(reglist)
    for index in range(len(reglist)):
        curr_tc = reglist[index];
        seed = random.randint(1,10000000)
        if(curr_tc['num'] != 0):
            cmd = "make regress tc=" + curr_tc['tc_name'] + " seed=" + str(seed) + " mode=" + reg_mode
            print(cmd)
            sim_result = subps.getstatusoutput(cmd)
            invalid_resp = 1
            for line in sim_result:
                if(type(line) == str):
                     if(re.search("PASS", line)):
                        invalid_resp = 0
                        pass_num += 1
                        break
                     elif (re.search("FAIL", line)):
                        invlid_resp = 0
                        fail_num += 1
                        fail_case_list.append(cmd)
                        break

            if(invalid_resp):
                invalid_num += 1
            finish_num += 1
            print("=================================")
            print("Finish Number: " + str(finish_num))
            print("PASS Number: " + str(pass_num))
            print("FAIL Number: " + str(fail_num))
            print("Invalid Number: " + str(invalid_num))
            print("=================================")
            reglist[index]["num"] -= 1

        with open(log_file, "w") as f:
            f.write("Finish Number: " + str(finish_num) + "\n")
            f.write("PASS Number: " + str(pass_num) + "\n")
            f.write("FAIL Number: " + str(fail_num) + "\n")
            f.write("Invalid Number: " + str(invalid_num) + "\n")
            for line in fail_case_list:
                f.write(line + " \n")
            f.close()

print("Regression Finish")
