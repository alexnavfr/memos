# Some prompts for SRM (Natixis)

## Prompt
_To search inside the SRM_Relaunch table the list of filter name and effect to relaunch.

```sql
select taskid from SRM_Relaunch where AsofDate = <dateof> and JobName = 'M32DRelaunchHypo';
```

```sql
select filtername, effect from SRM_task_CPNL where Active= 1 and ID in ( select tskid from SRM_Relaunch where AsofDate = <dateof> and JobName = 'M32DRelaunchHypo')
```
Use it as a egrep to search the "hypo_compute_pnl.pl" in the "travaux" directory.
for exemple in this directory:
/slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/travaux
Take into account the "--copy-to" parameter in the HYPO relauch file by relying on the "--effect-name" + "--filter" combination.

Exemple doing a grep for "--filter CPNL_06211" and "--effect-name=correltaux"
of if it return nothing do the following grep

 "--filter CPNL_06211" and "--copy-to correltaux"
because some effect or just a copy of another one.
after that 
it will return this line

```bash
hypo_compute_pnl.pl --effect-name=spreadtaux --filter=CPNL_06193 --cvid=MOJSPRE --xydate=130226 --report-date=20260216 --pnl-args="-XML -FR..." --utput-dir=/slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/cft/NSDCVFT.wait/ --copy-to voltaux/MOJVOL --copy-to smiletaux/MOJSMILE --copy-to correltaux/MOJCOR --copy-to smilefx/MOJSMIFX --copy-to fx/MOJFX --copy-to volfx/MOJVFX 1> slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS//logs/XFRDCalcPNLSpredTaux/PNL_COMPUTE_CPNL_06193_EFFECT_SPREADTAUX.log
```
The JobName must be replaced by M32DRelaunchHypo so XFRDCalcPNLSpredTaux will become M32DRelaunchHypo

```bash
appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/cft/NSDCVFT.wait/ --copy-to voltaux/MOJVOL --copy-to smiletaux/MOJSMILE --copy-to correltaux/MOJCOR --copy-to smilefx/MOJSMIFX --copy-to fx/MOJFX --copy-to volfx/MOJVFX 1> slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS//logs/M32DRelaunchHypo/PNL_COMPUTE_CPNL_06193_EFFECT_SPREADTAUX.log
```

Then we add it in a temporary file of reprise.cmd for closing PARIS
And execute the reprise.cmd with script of environment

```bash
appSetEnv M32_PROD_HYPO
```

When reprise.cmd is finished we must delete the line in SRM_Relaunch table to avoide re-execution of the script._