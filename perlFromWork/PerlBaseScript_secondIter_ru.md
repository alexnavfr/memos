# Вторая версия изменения для HYPO

## Prompt 2:
_Спасибо. Давай приведи теперь полную версию уже измененного скрипта с учетом всех важных замечаний._

Вот полная версия измененного скрипта с единообразной обработкой HYPO и PL:

```perl
#!/usr/bin/env perl

BEGIN {
  my $program_dir = $0;
  $program_dir =~ s{^(.*/).*?$}{$1};

  push @INC, $program_dir;
  push @INC, "$ENV{'SPEHOME'}/sbin/";
}

use strict;
no strict 'refs';
use Date::Calc qw(Delta_Days);
use File::stat;
use CPNL::COMMON;
use CPNL::ENV_VARS;
use CPNL::SQL;

# Declare the variables
my $help;
my $_PARAMS_CVID_FILE;
my $_BATCHDATE;
my $_TEMPLATE_FILTER;
my $_TEMPLATE_FILTERSEC;
my $_GRID_CMD_FILE;
my $_FILTERS_FILE;

GetOptions(
'h|H' =>\$help,
'PCF=s' =>\$_PARAMS_CVID_FILE,
'BATCHDATE=s' =>\$_BATCHDATE,
'TPL_FILTER=s' =>\$_TEMPLATE_FILTER,
'TPL_FILTERSEC=s' =>\$_TEMPLATE_FILTERSEC,
'FILTERS_FILE=s' =>\$_FILTERS_FILE,
'GRID_CMD_FILE=s' =>\$_GRID_CMD_FILE
) ;

if ($help) {
  print " |     Prog $0 \n";
  print " ----------------------------------------------------------------------- \n";
  print " |                                                                     | \n";
  print " | -H              : Help                                              | \n";
  print " | -PCF            : Params and CVID file                              | \n";
  print " | -BATCHDATE      : date to keep a trace of the execution             | \n";
  print " | -TPL_FILTER     : Template file to be used for the filters          | \n";
  print " | -TPL_FILTERSEC  : Template file to be used for the filters Sec      | \n";
  print " | -CFG            : CFG file to be created (for the P&L API)          | \n";
  print " | -GRID_CMD_FILE  : Name of the file containing commands for the Grid | \n";
  print " | -FILTERS_FILE   : Name of the file to write the filters in          | \n";
  print " |                                                                     | \n";
  print " ----------------------------------------------------------------------- \n";

  die ("\n\nHope this helps\n\n");
}

die ("\nThe parameter -BATCHDATE is missing \n") if !$_BATCHDATE;
die ("\nThe parameter -PCF is missing \n") if !$_PARAMS_CVID_FILE;
die ("\nThe parameter -TPL_FILTER is missing \n") if !$_TEMPLATE_FILTER;
die ("\nThe parameter -TPL_FILTERSEC is missing \n") if !$_TEMPLATE_FILTERSEC;
die ("\nThe parameter -GRID_CMD_FILE is missing \n") if !$_GRID_CMD_FILE;
die ("\nThe parameter -FILTERS_FILE is missing \n") if !$_FILTERS_FILE;

######################################################
# Prepare inserting query to be used later
######################################################
my ${cpnl_get_new_max_tasks_id} = CPNL::COMMON::prepare_query($CPNL::SQL::get_new_max_tasks_id);
my ${cpnl_insert} = CPNL::COMMON::prepare_query("INSERT INTO SRM_Tasks_CPNL (Id, Priority, RunType, Desk, Book, TradeType, FilterName, GroupFilterName, TemplateUsed, TradesExcluded, CVID, Closing, FromTradeDate, ToTradeDate, FromMatDate, ToMatDate, X_Date, Y_Date, EnvVars, CommandLine, TableTemp, TableFinal, NbTrades, CopyTo, Active, FromFinalMaturity,EffectId) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
my ${cpnl_update} = CPNL::COMMON::prepare_query($CPNL::SQL::req_update_params);
# Удалены специальные запросы для HYPO
# my ${cpnl_update_hypo} = CPNL::COMMON::prepare_query($CPNL::SQL::req_update_params_hypo);
# my ${cpnl_delete_hypo} = CPNL::COMMON::prepare_query($CPNL::SQL::req_delete_hypo_lines);
my ${cpnl_activate} = CPNL::COMMON::prepare_query($CPNL::SQL::req_activate_params);

# Remove GroupFilter Information (will be set in subsequent scripts)
my ${cpnl_remove_groups} = CPNL::COMMON::prepare_query($CPNL::SQL::req_remove_groups);
${cpnl_remove_groups}->execute();
${cpnl_remove_groups}->finish;

# And deactivate all Params (will be activated on a per-row basis)
my ${cpnl_deactivate_all} = CPNL::COMMON::prepare_query($CPNL::SQL::req_deactivate_all_params);
${cpnl_deactivate_all}->execute();
${cpnl_deactivate_all}->finish;

######################################################
# We read the SDR exclusions from DB into an array
######################################################
my ${list_exclusions_sdr} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_SDR_excl);
$list_exclusions_sdr->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");

my @sdr_excl_array;
while (my @exclusion = $list_exclusions_sdr->fetchrow_array) {

  my ($sdr_book, $sdr_tt, $sdr_comment) = @exclusion;
  print "req_select_SDR_excl $sdr_book,$sdr_tt,$sdr_comment\n";
  push @sdr_excl_array, $sdr_book.'.'.$sdr_tt;
}
$list_exclusions_sdr->finish;

######################################################
# We read the main CVID into an array
######################################################
my @main_cvid_array;
my ${list_main_cvid} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_mr_main_cvid);
$list_main_cvid->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
while (my @cur_main_cvid = $list_main_cvid->fetchrow_array) {
  my (${cvid}) = @cur_main_cvid;
  print "req_select_mr_main_cvid $cvid\n";

  push @main_cvid_array, ${cvid};
}

######################################################
# We read the actual P&L data (DB) into a hash
######################################################
my %cpnl_filters_params_hash;
my %cpnl_filters_names_hash;
my @cpnl_filters_nums_array;
my ${list_cpnl} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_params);
$list_cpnl->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
while (my @cur_cpnl = $list_cpnl->fetchrow_array) {
  my (${Id}, ${Priority}, ${RunType}, ${Desk}, ${Book}, ${TradeType}, ${FilterName}, ${GroupFilterName}, ${TemplateUsed}, ${TradesExcluded}, ${CVID}, ${Closing}, ${From_TradeDate}, ${To_TradeDate}, ${From_MatDate}, ${To_MatDate}, ${X_Date}, ${Y_Date}, ${EnvVars}, ${CommandLine}, ${TableTemp}, ${TableFinal}, ${Nb_Trades}, ${CopyTo}, ${Active},${From_FinalMaturity}) = @cur_cpnl;
  ${Id} = CPNL::COMMON::trim(${Id});
  ${Priority} = CPNL::COMMON::trim(${Priority});
  ${RunType} = CPNL::COMMON::trim(${RunType});
  ${Desk} = CPNL::COMMON::trim(${Desk});
  ${Book} = CPNL::COMMON::trim(${Book});
  ${TradeType} = CPNL::COMMON::trim(${TradeType});
  ${FilterName} = CPNL::COMMON::trim(${FilterName});
  ${GroupFilterName} = CPNL::COMMON::trim(${GroupFilterName});
  ${TemplateUsed} = CPNL::COMMON::trim(${TemplateUsed});
  ${TradesExcluded} = CPNL::COMMON::trim(${TradesExcluded});
  ${CVID} = CPNL::COMMON::trim(${CVID});
  ${Closing} = CPNL::COMMON::trim(${Closing});
  ${From_TradeDate} = CPNL::COMMON::trim(${From_TradeDate});
  ${To_TradeDate} = CPNL::COMMON::trim(${To_TradeDate});
  ${From_MatDate} = CPNL::COMMON::trim(${From_MatDate});
  ${To_MatDate} = CPNL::COMMON::trim(${To_MatDate});
  ${X_Date} = CPNL::COMMON::trim(${X_Date});
  ${Y_Date} = CPNL::COMMON::trim(${Y_Date});
  ${EnvVars} = CPNL::COMMON::trim(${EnvVars});
  ${CommandLine} = CPNL::COMMON::trim(${CommandLine});
  ${TableTemp} = CPNL::COMMON::trim(${TableTemp});
  ${TableFinal} = CPNL::COMMON::trim(${TableFinal});
  ${Nb_Trades} = CPNL::COMMON::trim(${Nb_Trades});
  ${CopyTo} = CPNL::COMMON::trim(${CopyTo});
  ${Active} = CPNL::COMMON::trim(${Active});
  ${From_FinalMaturity} = CPNL::COMMON::trim(${From_FinalMaturity});
  #print "req_select_params:${FilterName},${RunType},${Active}\n";
  # We want to store only ref Hypo into the hash
  if (${RunType} eq 'HYPO' &&
      !CPNL::COMMON::in_array(${CVID}, @main_cvid_array)) {
    next;
  }

  my $start_loc = length(${FilterName}) - $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT;
  my ${FilterNumber} = substr(${FilterName}, $start_loc, $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT);
  $cpnl_filters_params_hash{${RunType}.';'.$Desk.';'.$Book.';'.$TradeType} = {'ID' => ${Id},
                                                                              'Priority' => ${Priority},
                                                                              'RunType' => ${RunType},
                                                                              'FilterName' => ${FilterName},
                                                                              'GroupFilterName' => ${GroupFilterName},
                                                                              'FilterNumber' => ${FilterNumber},
                                                                              'TemplateUsed' => ${TemplateUsed},
                                                                              'TradesExcluded' => ${TradesExcluded},
                                                                              'CVID' => ${CVID},
                                                                              'Closing' => ${Closing},
                                                                              'From_TradeDate' => ${From_TradeDate},
                                                                              'To_TradeDate' => ${To_TradeDate},
                                                                              'From_MatDate' => ${From_MatDate},
                                                                              'To_MatDate' => ${To_MatDate},
                                                                              'X_Date' => ${X_Date},
                                                                              'Y_Date' => ${Y_Date},
                                                                              'EnvVars' => ${EnvVars},
                                                                              'CommandLine' => ${CommandLine},
                                                                              'TableTemp' => ${TableTemp},
                                                                              'TableFinal' => ${TableFinal},
                                                                              'Nb_Trades' => ${Nb_Trades},
                                                                              'CopyTo' => ${CopyTo},
                                                                              'Active' => ${Active},
                                                                              'From_FinalMaturity' => ${From_FinalMaturity}};
  $cpnl_filters_names_hash{$Desk.';'.$Book.';'.$TradeType} = CPNL::COMMON::trim(${FilterName});
  push @cpnl_filters_nums_array, ${FilterNumber};
}
$list_cpnl->finish;

# Sort
@cpnl_filters_nums_array = sort(@cpnl_filters_nums_array);

# Unique
my %hash_tmp = map { $_ => 1 } @cpnl_filters_nums_array;
@cpnl_filters_nums_array = sort keys %hash_tmp;

######################################################
# We read the actual P&L data for splitted filter (DB) into a hash
######################################################
my %cpnl_filters_splitted_params_hash;
my %cpnl_filters_splitted_names_hash;
my @cpnl_filters_splitted_nums_array;
${list_cpnl} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_splitted_params);
$list_cpnl->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");

print "EXECUTE!!!!!!!req_select_splitted_params \n";
print "EXECUTE!!!!!!!req_select_splitted_params \n";
print "EXECUTE!!!!!!!req_select_splitted_params \n";
print "EXECUTE!!!!!!!req_select_splitted_params \n";

while (my @cur_cpnl = $list_cpnl->fetchrow_array) {
  my (${Id}, ${Priority}, ${RunType}, ${Desk}, ${Book}, ${TradeType}, ${FilterName}, ${GroupFilterName}, ${TemplateUsed}, ${TradesExcluded}, ${CVID}, ${Closing}, ${From_TradeDate}, ${To_TradeDate}, ${From_MatDate}, ${To_MatDate}, ${X_Date}, ${Y_Date}, ${EnvVars}, ${CommandLine}, ${TableTemp}, ${TableFinal}, ${Nb_Trades}, ${CopyTo}, ${Active},${From_FinalMaturity}) = @cur_cpnl;
  ${Id} = CPNL::COMMON::trim(${Id});
  ${Priority} = CPNL::COMMON::trim(${Priority});
  ${RunType} = CPNL::COMMON::trim(${RunType});
  ${Desk} = CPNL::COMMON::trim(${Desk});
  ${Book} = CPNL::COMMON::trim(${Book});
  ${TradeType} = CPNL::COMMON::trim(${TradeType});
  ${FilterName} = CPNL::COMMON::trim(${FilterName});
  ${GroupFilterName} = CPNL::COMMON::trim(${GroupFilterName});
  ${TemplateUsed} = CPNL::COMMON::trim(${TemplateUsed});
  ${TradesExcluded} = CPNL::COMMON::trim(${TradesExcluded});
  ${CVID} = CPNL::COMMON::trim(${CVID});
  ${Closing} = CPNL::COMMON::trim(${Closing});
  ${From_TradeDate} = CPNL::COMMON::trim(${From_TradeDate});
  ${To_TradeDate} = CPNL::COMMON::trim(${To_TradeDate});
  ${From_MatDate} = CPNL::COMMON::trim(${From_MatDate});
  ${To_MatDate} = CPNL::COMMON::trim(${To_MatDate});
  ${X_Date} = CPNL::COMMON::trim(${X_Date});
  ${Y_Date} = CPNL::COMMON::trim(${Y_Date});
  ${EnvVars} = CPNL::COMMON::trim(${EnvVars});
  ${CommandLine} = CPNL::COMMON::trim(${CommandLine});
  ${TableTemp} = CPNL::COMMON::trim(${TableTemp});
  ${TableFinal} = CPNL::COMMON::trim(${TableFinal});
  ${Nb_Trades} = CPNL::COMMON::trim(${Nb_Trades});
  ${CopyTo} = CPNL::COMMON::trim(${CopyTo});
  ${Active} = CPNL::COMMON::trim(${Active});
  ${From_FinalMaturity} = CPNL::COMMON::trim(${From_FinalMaturity});

  print "req_select_splitted_params:${FilterName},${RunType},${Active}\n";

  my $start_loc = length(${FilterName}) - $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT + 1; # + 1 because the tens of thousands are for types of filters
  my ${FilterNumber} = substr(${FilterName}, $start_loc, $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT);
  $cpnl_filters_splitted_params_hash{${RunType}.';'.$Desk.';'.$Book.';'.$TradeType.';'.$From_TradeDate.';'.${To_TradeDate}} = {
                                                                              'ID' => ${Id},
                                                                              'Priority' => ${Priority},
                                                                              'RunType' => ${RunType},
                                                                              'FilterName' => ${FilterName},
                                                                              'GroupFilterName' => ${GroupFilterName},
                                                                              'FilterNumber' => ${FilterNumber},
                                                                              'TemplateUsed' => ${TemplateUsed},
                                                                              'TradesExcluded' => ${TradesExcluded},
                                                                              'CVID' => ${CVID},
                                                                              'Closing' => ${Closing},
                                                                              'From_TradeDate' => ${From_TradeDate},
                                                                              'To_TradeDate' => ${To_TradeDate},
                                                                              'From_MatDate' => ${From_MatDate},
                                                                              'To_MatDate' => ${To_MatDate},
                                                                              'X_Date' => ${X_Date},
                                                                              'Y_Date' => ${Y_Date},
                                                                              'EnvVars' => ${EnvVars},
                                                                              'CommandLine' => ${CommandLine},
                                                                              'TableTemp' => ${TableTemp},
                                                                              'TableFinal' => ${TableFinal},
                                                                              'Nb_Trades' => ${Nb_Trades},
                                                                              'CopyTo' => ${CopyTo},
                                                                              'Active' => ${Active},
                                                                              'From_FinalMaturity' => ${From_FinalMaturity}};
            print "cpnl_filters_splitted_names_hash = $Desk ,$Book,$TradeType,${From_TradeDate},${To_TradeDate}:${FilterName}\n";
  $cpnl_filters_splitted_names_hash{$Desk.';'.$Book.';'.$TradeType.';'.${From_TradeDate}.';'.${To_TradeDate}} = CPNL::COMMON::trim(${FilterName});
  push @cpnl_filters_splitted_nums_array, ${FilterNumber};
}
$list_cpnl->finish;

# Sort
@cpnl_filters_splitted_nums_array = sort(@cpnl_filters_splitted_nums_array);

# Unique
my %hash_tmp = map { $_ => 1 } @cpnl_filters_splitted_nums_array;
@cpnl_filters_splitted_nums_array = sort keys %hash_tmp;

######################################################
# We read the Technical exclusions into a hash
######################################################
my %exclusions_tech_hash;
my ${list_exclusions_tech} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_excl_tech);
$list_exclusions_tech->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
while (my @cur_exclusion_tech = $list_exclusions_tech->fetchrow_array) {
  my (${closing}, ${desk}, ${book}, ${trade_type}, ${trade_id_list}, ${comment}) = @cur_exclusion_tech;
  print "req_select_excl_tech:${closing},${desk},${trade_type},${trade_id_list}\n";
  my @trade_id_array = split(/,/, ${trade_id_list});
  foreach my $trade_id (@trade_id_array) {
    $trade_id = CPNL::COMMON::trim($trade_id);
    if (${trade_id} eq '') { next; }

    $exclusions_tech_hash{${desk}.';'.${book}.';'.${trade_type}} .= '-'.${trade_id};
  }
}

# УДАЛЕНО: Чтение трансформации CVID для HYPO - теперь все типы обрабатываются одинаково
# my %hypo_cvid_transco_hash;
# ... код удален ...

######################################################
# We read the templates files into arrays
######################################################

open (my $FIC_IN_TEMPLATE_FILTER,"<${CPNL::ENV_VARS::CONFIG}/${_TEMPLATE_FILTER}") or CPNL::COMMON::mydie("Error opening file ${CPNL::ENV_VARS::CONFIG}/${_TEMPLATE_FILTER} - ".$!);
my (@filter_template_array) = <$FIC_IN_TEMPLATE_FILTER>;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(stat($FIC_IN_TEMPLATE_FILTER)->mtime);
my $template_modified_days = Delta_Days($year + 1900, CPNL::COMMON::get_month($mon), CPNL::COMMON::get_day($mday),
                                        substr($_BATCHDATE, 0, 4), substr($_BATCHDATE, 4, 2), substr($_BATCHDATE, 6, 2));
my $must_update_all_filters = 0;
if ($template_modified_days >= 0 &&
    $template_modified_days <= ${CPNL::ENV_VARS::_TEMPLATES_MODIFIED_SECURITY_DAYS}) {
  $must_update_all_filters = 1;
  print "File ${CPNL::ENV_VARS::CONFIG}/${_TEMPLATE_FILTER} has been modified less than ${CPNL::ENV_VARS::_TEMPLATES_MODIFIED_SECURITY_DAYS} days ago : we must update ALL filters !\n";
}
close($FIC_IN_TEMPLATE_FILTER);

open (FIC_IN_TEMPLATE_FILTERSEC,"<${CPNL::ENV_VARS::CONFIG}/${_TEMPLATE_FILTERSEC}") or CPNL::COMMON::mydie("Error opening file ${CPNL::ENV_VARS::CONFIG}/${_TEMPLATE_FILTERSEC} - ".$!);
my (@filtersec_template_array) = <FIC_IN_TEMPLATE_FILTERSEC>;
close(FIC_IN_TEMPLATE_FILTERSEC);

######################################################
# We read the Template Exclusions (DB) into a hash
######################################################
my %filter_tmpl_exclusions_hash;
my %templates_to_update;
my ${list_exclusions} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_excl_templ);
$list_exclusions->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
while (my @exclusion = $list_exclusions->fetchrow_array) {
  my ($TmplAudit_DateTime, $TmplName, $ExclElement, $ExclValue) = @exclusion;

  $filter_tmpl_exclusions_hash{$TmplName} .= '<'.$ExclElement.'>';
  $filter_tmpl_exclusions_hash{$TmplName} .= $ExclValue;
  $filter_tmpl_exclusions_hash{$TmplName} .= '</'.$ExclElement.'>';

  my $template_modified_days = Delta_Days(substr($TmplAudit_DateTime, 0, 4), substr($TmplAudit_DateTime, 4, 2), substr($TmplAudit_DateTime, 6, 2),
                                          substr($_BATCHDATE, 0, 4), substr($_BATCHDATE, 4, 2), substr($_BATCHDATE, 6, 2));
  if ($must_update_all_filters == 1) {
    $templates_to_update{$TmplName} = 1;
  }
  elsif ($template_modified_days >= 0 &&
      $template_modified_days <= ${CPNL::ENV_VARS::_TEMPLATES_MODIFIED_SECURITY_DAYS}) {
    $templates_to_update{$TmplName} = 1;
  }
}
$list_exclusions->finish;

#################################################################
# The filters creation begins : First, add/update Run Parameters
#################################################################
my ${filter_name} = '';
my ${filter_num} = '';
my ${flag_import_filter} = 0;
my ${flag_new_filter} = 0;
my @cpnl_filters_to_create_array;
my @cpnl_filters_to_create_names_array;
my $new_id = 0;
my $_MUST_PRODUCT;
print "_PARAMS_CVID_FILE ${_PARAMS_CVID_FILE} \n";
open (FIC_IN_PARAMS_CVID,"<$CPNL::ENV_VARS::SUMMITSPOOLDIR/${_PARAMS_CVID_FILE}");
while (my $line=<FIC_IN_PARAMS_CVID>) {
  chomp($line);
  print "FIC_IN_PARAMS_CVID $line \n";
  my (${_RUN_TYPE}, ${_TEMPLATE_USED}, ${_DESK}, ${_BOOK}, ${_TRADE_TYPE}, ${_FROM_MAT_DATE}, ${_TO_MAT_DATE}, ${_CVID}, ${_X_DATE}, ${_Y_DATE}, ${_ENV_VARS}, ${_COMMAND_LINE}, ${_NB_TRADES}, ${_COPY_TO}, ${_COPY_TO_SDR}, ${_PRIORITY}, ${_MIN_TRADE_DATE}, ${_TABLE_FINAL}, ${_SPLIT_THRESHOLD},${_FROM_FINAL_MATURITY}) = split(/;/, $line);

  # Concat different copy to locations
  my $_NEW_COPY_TO = "";
  # Added ALL as a TradeType because SDR said so...
  if ((!CPNL::COMMON::in_array(${_BOOK}.'.'.${_TRADE_TYPE}, @sdr_excl_array)) && (!CPNL::COMMON::in_array(${_BOOK}.'.ALL', @sdr_excl_array))) {
    $_NEW_COPY_TO = CPNL::COMMON::trim(${_COPY_TO_SDR})."|";
  }
  if (CPNL::COMMON::trim(${_COPY_TO}) ne "") {
    $_NEW_COPY_TO .= CPNL::COMMON::trim(${_COPY_TO})."|";
  }

  # Excluded Trades generation
  my ${_TRADES_EXCLUDED} = $exclusions_tech_hash{${_DESK}.';'.${_BOOK}.';'.${_TRADE_TYPE}};
  if (!${_TRADES_EXCLUDED}) {
    ${_TRADES_EXCLUDED} = '';
  }

  # Specific modifs if MUST_TR
  if (CPNL::COMMON::in_array(CPNL::COMMON::trim(${_TRADE_TYPE}), @CPNL::COMMON::must_types)) {
    ${_MUST_PRODUCT} = CPNL::COMMON::trim(${_TRADE_TYPE});
    ${_TRADE_TYPE} = "MUST_TR";
  }
  else {
    ${_MUST_PRODUCT} = ${_TRADE_TYPE};
  }

  my $new_filter_params_hash_ref = {'Priority' => CPNL::COMMON::trim(${_PRIORITY}),
                                    'RunType' => CPNL::COMMON::trim(${_RUN_TYPE}),
                                    'Desk' => CPNL::COMMON::trim(${_DESK}),
                                    'Book' => CPNL::COMMON::trim(${_BOOK}),
                                    'TradeType' => CPNL::COMMON::trim(${_TRADE_TYPE}),
                                    'TemplateUsed' => CPNL::COMMON::trim(${_TEMPLATE_USED}),
                                    'TradesExcluded' => CPNL::COMMON::trim(${_TRADES_EXCLUDED}),
                                    'CVID' => CPNL::COMMON::trim(${_CVID}),
                                    'From_TradeDate' => '',
                                    'To_TradeDate' => '',
                                    'From_MatDate' => CPNL::COMMON::trim(${_FROM_MAT_DATE}),
                                    'To_MatDate' => CPNL::COMMON::trim(${_TO_MAT_DATE}),
                                    'Min_TradeDate' => CPNL::COMMON::trim(${_MIN_TRADE_DATE}),
                                    'X_Date' => CPNL::COMMON::trim(${_X_DATE}),
                                    'Y_Date' => CPNL::COMMON::trim(${_Y_DATE}),
                                     'From_FinalMaturity' => CPNL::COMMON::trim(${_FROM_FINAL_MATURITY}),
                                    'EnvVars' => CPNL::COMMON::trim(${_ENV_VARS}),
                                    'CommandLine' => CPNL::COMMON::trim(${_COMMAND_LINE}),
                                    'TableFinal' => CPNL::COMMON::trim(${_TABLE_FINAL}),
                                    'Nb_Trades' => CPNL::COMMON::trim(${_NB_TRADES}),
                                    'MustProduct' => CPNL::COMMON::trim(${_MUST_PRODUCT}),
                                    'CopyTo' => CPNL::COMMON::trim(${_NEW_COPY_TO})};
  my %new_filter_params_hash = %$new_filter_params_hash_ref;

  my %cur_filter_params_hash;
  my @filters_to_treat;
  ${filter_num} = '';
  ${filter_name} = '';
  print "_SPLIT_THRESHOLD=${_SPLIT_THRESHOLD} Nb_Trades ${_NB_TRADES} \n";
  if (${new_filter_params_hash}{'Nb_Trades'} <= ${_SPLIT_THRESHOLD})
  {
    if ($cpnl_filters_params_hash{$new_filter_params_hash{'RunType'}.';'.$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}})
            {
      %cur_filter_params_hash = %{$cpnl_filters_params_hash{$new_filter_params_hash{'RunType'}.';'.$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}}};
    }
    ${filter_name} = $cpnl_filters_names_hash{$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}};
    ${filter_num} = $cur_filter_params_hash{'FilterNumber'};

    $new_filter_params_hash{'From_TradeDate'} =  '';
    $new_filter_params_hash{'To_TradeDate'} = '';

    push @filters_to_treat, {'cur_params' => {%cur_filter_params_hash},
                             'new_params' => {%new_filter_params_hash},
                             'filter_name' => ${filter_name},
                             'filter_num'  => ${filter_num}};
  }
  else {
            print "_SPLIT_THRESHOLD=${_SPLIT_THRESHOLD} ${_NB_TRADES}\n";

    print "Filter TO SPLIT!!!! ${_DESK},${_BOOK},${_TRADE_TYPE} \n";

            my %TradeDate_Hash = &get_tradedate_count_list($new_filter_params_hash{'Book'}, $new_filter_params_hash{'MustProduct'}, $CPNL::ENV_VARS::CLOSING);

            print " after Filter get_tradedate_count_list ${_DESK},${_BOOK},${_TRADE_TYPE} \n";

            my $TradesCount = 0;
            my $SplitFrom_TradeDate =  '';
            my $SplitTo_TradeDate = '';
            my $Last_TradeDate = '';
            my $StartTradeDate = '';
            foreach my $TradeDate (sort keys %TradeDate_Hash){
            #print 'YMO TEST TradeDate : '.${TradeDate}."\n";
            $TradesCount += $TradeDate_Hash{$TradeDate};
#      print 'YMO TEST TradesCount: '.${TradesCount}.":\n";
                        $TradesCount >= ${_SPLIT_THRESHOLD} and $Last_TradeDate != '' and do{
                                   $SplitFrom_TradeDate = $StartTradeDate;
  #                                $StartTradeDate = $TradeDate;
                                    $SplitTo_TradeDate = $Last_TradeDate;
#        print 'YMO TEST SplitTo_TradeDate: '.${SplitTo_TradeDate}.":\n";
                                    $StartTradeDate = &calculateNextDate($SplitTo_TradeDate);
                                    $TradesCount = '0';

                                    # Creating data for the later filter creation
                                    $new_filter_params_hash{'From_TradeDate'} =  $SplitFrom_TradeDate;
                                    $new_filter_params_hash{'To_TradeDate'} = $SplitTo_TradeDate;
                                    %cur_filter_params_hash = {};
                                    exists $cpnl_filters_splitted_params_hash{$new_filter_params_hash{'RunType'}.';'.$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}.';'.$new_filter_params_hash{'From_TradeDate'}.';'.$new_filter_params_hash{'To_TradeDate'}} and do{
                                               %cur_filter_params_hash = %{$cpnl_filters_splitted_params_hash{$new_filter_params_hash{'RunType'}.';'.$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}.';'.$new_filter_params_hash{'From_TradeDate'}.';'.$new_filter_params_hash{'To_TradeDate'}}};
                                    };
                                    ${filter_name} = $cpnl_filters_splitted_names_hash{$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}.';'.$new_filter_params_hash{'From_TradeDate'}.';'.$new_filter_params_hash{'To_TradeDate'}};
                                    ${filter_num} = $cur_filter_params_hash{'FilterNumber'};

                                    push @filters_to_treat, {'cur_params' => {%cur_filter_params_hash},
                                 'new_params' => {%new_filter_params_hash},
                                 'filter_name' => ${filter_name},
                                 'filter_num'  => ${filter_num}};

                        };
                        $Last_TradeDate = $TradeDate;
#       print 'YMO TEST Last_TradeDate: '.${Last_TradeDate}.":\n";

            }
            # For the last filter
            $new_filter_params_hash{'From_TradeDate'} =  $StartTradeDate;
            $new_filter_params_hash{'To_TradeDate'} = '';
            %cur_filter_params_hash = {};
            exists $cpnl_filters_splitted_params_hash{$new_filter_params_hash{'RunType'}.';'.$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}.';'.$new_filter_params_hash{'From_TradeDate'}.';'.$new_filter_params_hash{'To_TradeDate'}} and do{
                        %cur_filter_params_hash = %{$cpnl_filters_splitted_params_hash{$new_filter_params_hash{'RunType'}.';'.$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}.';'.$new_filter_params_hash{'From_TradeDate'}.';'.$new_filter_params_hash{'To_TradeDate'}}};
            };
            ${filter_name} = $cpnl_filters_splitted_names_hash{$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}.';'.$new_filter_params_hash{'From_TradeDate'}.';'.$new_filter_params_hash{'To_TradeDate'}};
            ${filter_num} = $cur_filter_params_hash{'FilterNumber'};
    print "filterTo_treat filter_name=${filter_name}  from : $new_filter_params_hash{'Desk'}  filter_num=${filter_num} \n";
            push @filters_to_treat, {'cur_params' => {%cur_filter_params_hash},
                             'new_params' => {%new_filter_params_hash},
                             'filter_name' => ${filter_name},
                             'filter_num'  => ${

