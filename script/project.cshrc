#Get Main Folder Path
set workingpath = $cwd

while(1)
	if(-d "rtl" && -d "script" && -d "verification") then
		break
	endif
	cd ../
	if($cwd:t == "") then
		cd $workingpath
		echo "[Error] Cannot find the main folder path!"
		break
	endif
end

#Set Env Variable
setenv ELEC4320_FOLDER $cwd
setenv ELEC4320_RTL    $ELEC4320_FOLDER/rtl
setenv ELEC4320_COV    $ELEC4320_FOLDER/cov
setenv ELEC4320_SVA    $ELEC4320_FOLDER/sva
setenv ELEC4320_VER    $ELEC4320_FOLDER/verification
cd $workingpath

echo "[FOLDER] $ELEC4320_FOLDER"
echo "[RTL   ] $ELEC4320_RTL"
echo "[COV   ] $ELEC4320_COV"
echo "[SVA   ] $ELEC4320_SVA"
echo "[VERIFY] $ELEC4320_VER"

#UVM Path
setenv VCS_UVM_HOME /dfs/app/synopsys/vcs-vt2022.06-sp1-1/etc/uvm-1.2/src

#VCS setup
source /usr/eelocal/synopsys/vcs-vt2022.06-sp1-1/.cshrc
#Verdi setup
source /usr/eelocal/synopsys/verdi-vv2023.12/.cshrc 

