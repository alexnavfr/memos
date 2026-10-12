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
                             'filter_num'  => ${filter_num}};
  }

  foreach my $cur_filter_to_treat (@filters_to_treat) {
    my %cur_filter_to_treat_hash = %{$cur_filter_to_treat};
    my %cur_filter_params_hash = %{$cur_filter_to_treat_hash{'cur_params'}};
    my %new_filter_params_hash = %{$cur_filter_to_treat_hash{'new_params'}};
    ${filter_name} = $cur_filter_to_treat_hash{'filter_name'};
    ${filter_num} = $cur_filter_to_treat_hash{'filter_num'};

    ${flag_import_filter} = 0;
    ${flag_new_filter} = 0;

    # Filter exists in DB
    if (${filter_num}) {
      print 'Checking Filter '.${filter_name}.' ('.$new_filter_params_hash{'RunType'}.', '.$new_filter_params_hash{'Desk'}.', '.$new_filter_params_hash{'Book'}.', '.$new_filter_params_hash{'MustProduct'};
      if ($new_filter_params_hash{'From_TradeDate'} ne '' ||
          $new_filter_params_hash{'To_TradeDate'} ne '') {
        print ', TDateFrom = '.$new_filter_params_hash{'From_TradeDate'}.', TDateTo = '.$new_filter_params_hash{'To_TradeDate'};
      }
      print ").\n";

      # The filter must be imported if template used has been updated
      #   or if list of excluded Trades has changed
      #   or if template used has changed
      #   or if FromMatDate or has changed
      if ($new_filter_params_hash{'TemplateUsed'} ne $cur_filter_params_hash{'TemplateUsed'}) {
        print '  Must reimport Filter (only once) : The template has changed : old was '.$cur_filter_params_hash{'TemplateUsed'}.', new is '.$new_filter_params_hash{'TemplateUsed'}.".\n";
        ${flag_import_filter} = 1;
      }
      elsif ($new_filter_params_hash{'TradesExcluded'}  ne $cur_filter_params_hash{'TradesExcluded'}) {
        print '  Must reimport Filter (only once) : The list of excluded Trades has been updated.'."\n";
        ${flag_import_filter} = 1;
      }
      elsif ($templates_to_update{$new_filter_params_hash{'TemplateUsed'}}) {
        print '  Must reimport Filter (only once) : The template '.$new_filter_params_hash{'TemplateUsed'}.' has been updated less than '.${CPNL::ENV_VARS::_TEMPLATES_MODIFIED_SECURITY_DAYS}.' days ago.'."\n";
        ${flag_import_filter} = 1;
      }
      elsif ($new_filter_params_hash{'From_MatDate'} ne $cur_filter_params_hash{'From_MatDate'}) {
        print '  Must reimport Filter (only once) : From MatDate has changed.'."\n";
        ${flag_import_filter} = 1;
      }
      elsif ($new_filter_params_hash{'To_MatDate'} ne $cur_filter_params_hash{'To_MatDate'}) {
          print '  Must reimport Filter (only once) : To MatDate has changed.'."\n";
          ${flag_import_filter} = 1;
      }
      elsif ($new_filter_params_hash{'From_FinalMaturity'} ne $cur_filter_params_hash{'From_FinalMaturity'}) {
          print '  Must reimport Filter (only once) : To From FinalMaturity has changed.'."\n";
          ${flag_import_filter} = 1;
      }

      # Test if any of the Run Parameter has changed
      my $flag_differences_found = 0;
      # УДАЛЕНО: специальный флаг для HYPO - теперь все типы обрабатываются одинаково
      # my $flag_differences_hypo_cvid_found = 0;
      
      my @keys_to_compare = ('Priority', 'TemplateUsed', 'TradesExcluded', 'From_TradeDate', 'To_TradeDate', 'From_MatDate',
                             'To_MatDate', 'X_Date', 'Y_Date', 'EnvVars', 'CommandLine', 'TableFinal', 'Nb_Trades', 'CopyTo','From_FinalMaturity');
      foreach my $current_key (@keys_to_compare) {
        if ($new_filter_params_hash{$current_key} ne $cur_filter_params_hash{$current_key}) {
          print "  Difference found for ".$current_key." parameter (new : ".$new_filter_params_hash{$current_key}.", old : ".$cur_filter_params_hash{$current_key}.")\n";
          $flag_differences_found = 1;
        }
      }

      # УДАЛЕНО: специальная проверка для HYPO
      # if ($new_filter_params_hash{'RunType'} eq 'HYPO') {
      #   print "  Hypo run -> we 'll recreate the effects".")\n";
      #   $flag_differences_hypo_cvid_found = 1;
      # }

      if ($new_filter_params_hash{'CVID'} ne $cur_filter_params_hash{'CVID'}) {
        print "  Difference found for CVID parameter (new = ".$new_filter_params_hash{'CVID'}.", old = ".$cur_filter_params_hash{'CVID'}.")\n";
        $flag_differences_found = 1;
      }
      # Closing does not come from params hash
      if (${CPNL::ENV_VARS::CLOSING} ne $cur_filter_params_hash{'Closing'}) {
        print "  Difference found for Closing parameter (new = ".${CPNL::ENV_VARS::CLOSING}.", old = ".$cur_filter_params_hash{'Closing'}.")\n";
        $flag_differences_found = 1;
      }

      # УДАЛЕНО: специальная обработка для HYPO при изменении CVID
      # Вместо этого обрабатываем все типы одинаково
      
      if ($flag_differences_found == 1) {
            print '  Update Run Parameters'."\n";

            # ВСЕ ТИПЫ (включая HYPO) обновляют CVID одинаково
            # set
            ${cpnl_update}->bind_param(1 , $new_filter_params_hash{'Priority'});
            ${cpnl_update}->bind_param(2 , $new_filter_params_hash{'TemplateUsed'});

                                  if( length($new_filter_params_hash{'TradesExcluded'}) > 250)
                                  {
                                                       $new_filter_params_hash{'TradesExcluded'} =  substr($new_filter_params_hash{'TradesExcluded'}, 250) ;
                                  }

            ${cpnl_update}->bind_param(3 , $new_filter_params_hash{'TradesExcluded'});

                                   if( $new_filter_params_hash{'From_TradeDate'} eq  '')
                                           {
                                                               $new_filter_params_hash{'From_TradeDate'} = ' ';
                                           }

            ${cpnl_update}->bind_param(4 , $new_filter_params_hash{'From_TradeDate'});

                                    if( $new_filter_params_hash{'To_TradeDate'} eq  '')
                                           {
                                                               $new_filter_params_hash{'To_TradeDate'}= ' ';
                                           }

            ${cpnl_update}->bind_param(5 , $new_filter_params_hash{'To_TradeDate'});
            ${cpnl_update}->bind_param(6 , $new_filter_params_hash{'From_MatDate'});
            ${cpnl_update}->bind_param(7 , $new_filter_params_hash{'To_MatDate'});
            ${cpnl_update}->bind_param(8 , $new_filter_params_hash{'X_Date'});
            ${cpnl_update}->bind_param(9 , $new_filter_params_hash{'Y_Date'});
            ${cpnl_update}->bind_param(10 , $new_filter_params_hash{'From_FinalMaturity'});
            ${cpnl_update}->bind_param(11, $new_filter_params_hash{'EnvVars'});
            ${cpnl_update}->bind_param(12, $new_filter_params_hash{'CommandLine'});
            ${cpnl_update}->bind_param(13, $new_filter_params_hash{'TableFinal'});
            ${cpnl_update}->bind_param(14, $new_filter_params_hash{'Nb_Trades'});
            ${cpnl_update}->bind_param(15, $new_filter_params_hash{'CopyTo'});
            ${cpnl_update}->bind_param(16, $new_filter_params_hash{'CVID'});

            # where
            ${cpnl_update}->bind_param(17, $new_filter_params_hash{'RunType'});
            ${cpnl_update}->bind_param(18, $new_filter_params_hash{'Desk'});
            ${cpnl_update}->bind_param(19, $new_filter_params_hash{'Book'});
            ${cpnl_update}->bind_param(20, $new_filter_params_hash{'MustProduct'});
            ${cpnl_update}->bind_param(21, ${filter_name});
            ${cpnl_update}->bind_param(22, $new_filter_params_hash{'From_TradeDate'});
            ${cpnl_update}->bind_param(23, $new_filter_params_hash{'To_TradeDate'});
                                  print "cpnl_update execute : ${filter_name}\n";
            ${cpnl_update}->execute();
      }
      else {
            print '  Nothing to do, just keep it activated'."\n";
            if ($new_filter_params_hash{'Nb_Trades'} < $CPNL::ENV_VARS::_TRADES_THRESHOLD_LOW) {
               print '  Filter "might" be grouped because it has '.$new_filter_params_hash{'Nb_Trades'}.' Trades and the limit is set to '.$CPNL::ENV_VARS::_TRADES_THRESHOLD_LOW."\n";
            }

            ${cpnl_activate}->bind_param(1, $new_filter_params_hash{'RunType'});
            ${cpnl_activate}->bind_param(2, $new_filter_params_hash{'Desk'});
            ${cpnl_activate}->bind_param(3, $new_filter_params_hash{'Book'});
            ${cpnl_activate}->bind_param(4, $new_filter_params_hash{'MustProduct'});
                                   if($new_filter_params_hash{'From_TradeDate'} eq "")
                                   {
                                               ${cpnl_activate}->bind_param(5, ' ');
                                   }
                                   else
                                   {
                                               ${cpnl_activate}->bind_param(5, $new_filter_params_hash{'From_TradeDate'});
                                   }
                                   if($new_filter_params_hash{'To_TradeDate'} eq "")
                                   {
                                               ${cpnl_activate}->bind_param(6, ' ');
                                   }
                                   else
                                   {
                                               ${cpnl_activate}->bind_param(6, $new_filter_params_hash{'To_TradeDate'});
                                   }
                                   my $ret = ${cpnl_activate}->execute();

                                   print "cpnl_activate execute $ret : $new_filter_params_hash{'Book'},$new_filter_params_hash{'RunType'}, $new_filter_params_hash{'Desk'} ,${filter_name}\n";
         }
    }
    # Have to create new parameters
    else {
      my ${table_temp} = '';

      if (!${filter_name}) {
        my $padded_filter_num = '';
        if ($new_filter_params_hash{'From_TradeDate'} eq '' &&
            $new_filter_params_hash{'To_TradeDate'} eq '') {
          ${filter_num} = CPNL::COMMON::find_hole_in_array(@cpnl_filters_nums_array);

          if (${filter_num} == -1) {
            ${filter_num} = @cpnl_filters_nums_array[@cpnl_filters_nums_array - 1] + 1;
          }
          $padded_filter_num = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", ${filter_num});
          push @cpnl_filters_nums_array, $padded_filter_num;

          @cpnl_filters_nums_array = sort(@cpnl_filters_nums_array);

          ${filter_name} = ${CPNL::ENV_VARS::_FILTERS_NAME_PREFIX}."_".$padded_filter_num;
          $cpnl_filters_names_hash{$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}} = ${filter_name};
        }
        else {
          ${filter_num} = CPNL::COMMON::find_hole_in_array(@cpnl_filters_splitted_nums_array);

          if (${filter_num} == -1) {
            ${filter_num} = @cpnl_filters_splitted_nums_array[@cpnl_filters_splitted_nums_array - 1] + 1;
          }
          $padded_filter_num = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", ${filter_num} + ${CPNL::ENV_VARS::_SPLIT_FILTERS_START_NUM});
          push @cpnl_filters_splitted_nums_array, substr(${padded_filter_num}, 1, $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT);

          @cpnl_filters_splitted_nums_array = sort(@cpnl_filters_splitted_nums_array);

          ${filter_name} = ${CPNL::ENV_VARS::_FILTERS_NAME_PREFIX}."_".$padded_filter_num;
          $cpnl_filters_splitted_names_hash{$new_filter_params_hash{'Desk'}.';'.$new_filter_params_hash{'Book'}.';'.$new_filter_params_hash{'MustProduct'}.';'.$new_filter_params_hash{'From_TradeDate'}.';'.$new_filter_params_hash{'To_TradeDate'}} = ${filter_name};
        }

                        if ($new_filter_params_hash{'RunType'} eq "THETA")
                        {
                                   ${table_temp} = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_TTA_PREFIX}.${padded_filter_num};
                        }
                        else
                        {
                                   ${table_temp} = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_PREFIX}.${padded_filter_num};
                        }

      }
      else {
        my $start_loc = length(${filter_name}) - $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT;
        ${filter_num} = substr(${filter_name}, $start_loc, $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT);

                        if ($new_filter_params_hash{'RunType'} eq "THETA")
                        {
                                   ${table_temp} = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_TTA_PREFIX}.${filter_num};
                        }
                        else
                        {
                                   ${table_temp} = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_PREFIX}.${filter_num};
                        }

      }

      print 'New Run Parameters : '.${filter_name}.' ('.$new_filter_params_hash{'RunType'}.', '.$new_filter_params_hash{'Desk'}.', '.$new_filter_params_hash{'Book'}.', '.$new_filter_params_hash{'MustProduct'};
      if ($new_filter_params_hash{'From_TradeDate'} ne '' ||
          $new_filter_params_hash{'To_TradeDate'} ne '') {
        print ', TDateFrom = '.$new_filter_params_hash{'From_TradeDate'}.', TDateTo = '.$new_filter_params_hash{'To_TradeDate'};
      }
      print ").\n";

      ${cpnl_insert}->bind_param(2 , $new_filter_params_hash{'Priority'});
      ${cpnl_insert}->bind_param(3 , $new_filter_params_hash{'RunType'});
      ${cpnl_insert}->bind_param(4 , $new_filter_params_hash{'Desk'});
      ${cpnl_insert}->bind_param(5 , $new_filter_params_hash{'Book'});
      ${cpnl_insert}->bind_param(6 , $new_filter_params_hash{'MustProduct'});
      ${cpnl_insert}->bind_param(7 , ${filter_name});
      ${cpnl_insert}->bind_param(8 , ''); #GroupFilterName
      ${cpnl_insert}->bind_param(9 , $new_filter_params_hash{'TemplateUsed'});
              if( length($new_filter_params_hash{'TradesExcluded'}) > 250)
              {
                 $new_filter_params_hash{'TradesExcluded'} =  substr($new_filter_params_hash{'TradesExcluded'}, 250) ;
              }
      ${cpnl_insert}->bind_param(10, $new_filter_params_hash{'TradesExcluded'});
      ${cpnl_insert}->bind_param(11, $new_filter_params_hash{'CVID'});
      ${cpnl_insert}->bind_param(12, ${CPNL::ENV_VARS::CLOSING});

              if( $new_filter_params_hash{'From_TradeDate'} eq  '')
              {
                                   $new_filter_params_hash{'From_TradeDate'} = ' ';
              }

      ${cpnl_insert}->bind_param(13, $new_filter_params_hash{'From_TradeDate'});
              if( $new_filter_params_hash{'To_TradeDate'} eq  '')
              {
                                   $new_filter_params_hash{'To_TradeDate'} = ' ';
              }

      ${cpnl_insert}->bind_param(14, $new_filter_params_hash{'To_TradeDate'});
      ${cpnl_insert}->bind_param(15, $new_filter_params_hash{'From_MatDate'});
      ${cpnl_insert}->bind_param(16, $new_filter_params_hash{'To_MatDate'});
      ${cpnl_insert}->bind_param(17, $new_filter_params_hash{'X_Date'});
      ${cpnl_insert}->bind_param(18, $new_filter_params_hash{'Y_Date'});
      ${cpnl_insert}->bind_param(19, $new_filter_params_hash{'EnvVars'});
      ${cpnl_insert}->bind_param(20, $new_filter_params_hash{'CommandLine'});
      ${cpnl_insert}->bind_param(21, ${table_temp});
      ${cpnl_insert}->bind_param(22, $new_filter_params_hash{'TableFinal'});
      ${cpnl_insert}->bind_param(23, $new_filter_params_hash{'Nb_Trades'});
      ${cpnl_insert}->bind_param(24, $new_filter_params_hash{'CopyTo'});
      ${cpnl_insert}->bind_param(25, 1);
      ${cpnl_insert}->bind_param(26, $new_filter_params_hash{'From_FinalMaturity'});
              ${cpnl_insert}->bind_param(27, '');
              
      # ИЗМЕНЕНО: обработка HYPO теперь такая же, как для других типов
      if ($new_filter_params_hash{'RunType'} eq 'HYPO') {
        $new_id = $CPNL::COMMON::DbConnection->selectrow_array($cpnl_get_new_max_tasks_id);
        ${cpnl_insert}->bind_param(1 , $new_id);
        ${cpnl_insert}->bind_param(11, $new_filter_params_hash{'CVID'}); # Используем оригинальный CVID
        ${cpnl_insert}->bind_param(27, ''); # EffectId пустой как у других типов
        ${cpnl_insert}->execute();
      }
      else {
        $new_id = $CPNL::COMMON::DbConnection->selectrow_array($cpnl_get_new_max_tasks_id);
        ${cpnl_insert}->bind_param(1 , $new_id);
        ${cpnl_insert}->execute();
      }

      ${flag_import_filter} = 1;
      ${flag_new_filter} = 1;
    }

    if (${flag_import_filter} == 1 &&
        !CPNL::COMMON::in_array(${filter_name}, @cpnl_filters_to_create_names_array)) {
      push @cpnl_filters_to_create_names_array, ${filter_name};
      @cpnl_filters_to_create_names_array = sort(@cpnl_filters_to_create_names_array);

      push @cpnl_filters_to_create_array, {'Priority' => $new_filter_params_hash{'Priority'},
                                           'RunType' => $new_filter_params_hash{'RunType'},
                                           'Desk' => $new_filter_params_hash{'Desk'},
                                           'Book' => $new_filter_params_hash{'Book'},
                                           'TradeType' => $new_filter_params_hash{'TradeType'},
                                           'MustProduct' => $new_filter_params_hash{'MustProduct'},
                                           'FilterName' => ${filter_name},
                                           'TemplateUsed' => $new_filter_params_hash{'TemplateUsed'},
                                           'TradesExcluded' => $new_filter_params_hash{'TradesExcluded'},
                                           'CVID' => $new_filter_params_hash{'CVID'},
                                           'FromTradeDate' => $new_filter_params_hash{'From_TradeDate'},
                                           'ToTradeDate' => $new_filter_params_hash{'To_TradeDate'},
                                           'FromMatDate' => $new_filter_params_hash{'From_MatDate'},
                                           'ToMatDate' => $new_filter_params_hash{'To_MatDate'},
                                           'X_Date' => $new_filter_params_hash{'X_Date'},
                                           'Y_Date' => $new_filter_params_hash{'Y_Date'},
                                            'FromFinalMaturity' => $new_filter_params_hash{'From_FinalMaturity'},
                                           'EnvVars' => $new_filter_params_hash{'EnvVars'},
                                           'CommandLine' => $new_filter_params_hash{'CommandLine'},
                                           'NbTrades' => $new_filter_params_hash{'Nb_Trades'},
                                           'CopyTo' => $new_filter_params_hash{'CopyTo'},
                                           'Min_TradeDate' => $new_filter_params_hash{'Min_TradeDate'},
                                           'FlagNewFilter' => ${flag_new_filter}};

      if (${flag_new_filter} == 1) {
        print 'Create ';
      }
      else {
        print 'Update ';
      }
      print 'Filter : '.${filter_name}.' ('.$new_filter_params_hash{'Desk'}.', '.$new_filter_params_hash{'Book'}.', '.$new_filter_params_hash{'MustProduct'}.').'."\n";
    }
  }
}
${cpnl_get_new_max_tasks_id}->finish;
${cpnl_insert}->finish;
${cpnl_update}->finish;
# УДАЛЕНО: завершение специальных запросов для HYPO
# ${cpnl_update_hypo}->finish;
# ${cpnl_delete_hypo}->finish;
${cpnl_activate}->finish;

######################################################
# Open files
######################################################
open (FIC_OUT_GRID_CMD_FILE, ">$CPNL::ENV_VARS::SUMMITSPOOLDIR/${_GRID_CMD_FILE}");

my $count_filters_files = 0;
my $count_filters_files_padded = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", $count_filters_files);
my $out_filters_filename = "${CPNL::ENV_VARS::SUMMITSPOOLDIR}/${_FILTERS_FILE}.${count_filters_files_padded}";
open (FIC_OUT_FILTERS,">${out_filters_filename}") or CPNL::COMMON::mydie("Error opening file ${out_filters_filename} - ".$!);
print FIC_OUT_FILTERS "<ENTITYLIST>\n";
# And we must separate different entities into different files...
my $count_filters_sec_files = 0;
my $count_filters_sec_files_padded = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", $count_filters_sec_files);
my $out_filters_sec_filename = "${CPNL::ENV_VARS::SUMMITSPOOLDIR}/${_FILTERS_FILE}.SEC.${count_filters_sec_files_padded}";
open (FIC_OUT_FILTERS_SEC,">${out_filters_sec_filename}") or CPNL::COMMON::mydie("Error opening file ${out_filters_sec_filename} - ".$!);
print FIC_OUT_FILTERS_SEC "<ENTITYLIST>\n";

print FIC_OUT_GRID_CMD_FILE "static_import -XML -NEWACT IMLIVE -I ${out_filters_filename} -COMMIT\n";
print FIC_OUT_GRID_CMD_FILE "static_import -XML -NEWACT IMLIVE -I ${out_filters_sec_filename} -COMMIT\n";

#################################################################
# The filters creation continues : then, create filters to import
#################################################################
my $count_filters = 0;
my $count_filters_in_file = 0;
my $count_filters_sec_in_file = 0;
foreach my $cur_filter_to_create (@cpnl_filters_to_create_array) {
  my %cur_filter_to_create_hash = %{$cur_filter_to_create};

  ### /!\ Twice same code : create a function...
  # Should we create a new file for importing Filters ?
  if ($count_filters_in_file > $CPNL::ENV_VARS::_FILTERS_MAX_NB_IN_FILE) {
    print FIC_OUT_FILTERS "</ENTITYLIST>\n";
    close(FIC_OUT_FILTERS);

    $count_filters_files = $count_filters_files + 1;
    $count_filters_files_padded = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", $count_filters_files);
    $out_filters_filename = "${CPNL::ENV_VARS::SUMMITSPOOLDIR}/${_FILTERS_FILE}.${count_filters_files_padded}";
    print FIC_OUT_GRID_CMD_FILE "static_import -XML -NEWACT IMLIVE -I ${out_filters_filename} -COMMIT\n";
    open (FIC_OUT_FILTERS,">${out_filters_filename}") or CPNL::COMMON::mydie("Error opening file ${out_filters_filename} - ".$!);
    print FIC_OUT_FILTERS "<ENTITYLIST>\n";

    $count_filters_in_file = 0;
  }

  # Should we create a new file for importing Filters Sec ?
  if ($count_filters_sec_in_file > $CPNL::ENV_VARS::_FILTERS_MAX_NB_IN_FILE) {
    print FIC_OUT_FILTERS_SEC "</ENTITYLIST>\n";
    close(FIC_OUT_FILTERS_SEC);

    $count_filters_sec_files = $count_filters_sec_files + 1;
    $count_filters_sec_files_padded = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", $count_filters_sec_files);
    $out_filters_sec_filename = "${CPNL::ENV_VARS::SUMMITSPOOLDIR}/${_FILTERS_FILE}.SEC.${count_filters_sec_files_padded}";
    print FIC_OUT_GRID_CMD_FILE "static_import -XML -NEWACT IMLIVE -I ${out_filters_sec_filename} -COMMIT\n";
    open (FIC_OUT_FILTERS_SEC,">${out_filters_sec_filename}") or CPNL::COMMON::mydie("Error opening file ${out_filters_sec_filename} - ".$!);
    print FIC_OUT_FILTERS_SEC "<ENTITYLIST>\n";

    $count_filters_sec_in_file = 0;
  }

  $count_filters = $count_filters + 1;

  # We write a FilterSec Entity only if we have a NEW filter (not when it's an update)...
  if ($cur_filter_to_create_hash{'FlagNewFilter'} == 1) {
    for (my $i = 0; $i < @filtersec_template_array; $i++) {
      my $new_line = $filtersec_template_array[$i];
      $new_line =~s /__FILTER_NAME__/$cur_filter_to_create_hash{'FilterName'}/g;
      $new_line =~s /__ROLE_NAME__/${CPNL::ENV_VARS::_FILTERS_MODIF_ROLES}/g;

      print FIC_OUT_FILTERS_SEC "$new_line";
    }
    $count_filters_sec_in_file = $count_filters_sec_in_file + 1;
  }

  for (my $i = 0; $i < @filter_template_array; $i++) {
    my $new_line = $filter_template_array[$i];
    $new_line =~ s/__FILTER_NAME__/$cur_filter_to_create_hash{'FilterName'}/g;
    $new_line =~ s/__TEMPLATE_NAME__/$cur_filter_to_create_hash{'TemplateUsed'}/g;

            if (CPNL::COMMON::in_array($cur_filter_to_create_hash{'MustProduct'}, @CPNL::COMMON::must_types)) {
                        $new_line =~ s@__TRADE_TYPE__@MUST@g;
            }
            else {
                        $new_line =~ s@__TRADE_TYPE__@$cur_filter_to_create_hash{'MustProduct'}@g;
            }

    $new_line =~ s/__TRADE_TYPE__/$cur_filter_to_create_hash{'TradeType'}/g;
    $new_line =~ s/__DESK__/$cur_filter_to_create_hash{'Desk'}/g;
    $new_line =~ s/__BOOK__/$cur_filter_to_create_hash{'Book'}/g;
    $new_line =~ s/__FROM_TRADE_DATE__/$cur_filter_to_create_hash{'FromTradeDate'}/g;
    $new_line =~ s/__TO_TRADE_DATE__/$cur_filter_to_create_hash{'ToTradeDate'}/g;
    $new_line =~ s/__FROM_MAT_DATE__/$cur_filter_to_create_hash{'FromMatDate'}/g;
    $new_line =~ s/__TO_MAT_DATE__/$cur_filter_to_create_hash{'ToMatDate'}/g;
    $new_line =~ s/__FROM_FINAL_MATURITY__/$cur_filter_to_create_hash{'FromFinalMaturity'}/g;
    $new_line =~ s/__TRADES_EXCLUDED__/$cur_filter_to_create_hash{'TradesExcluded'}/g;
    $new_line =~ s/__TEMPLATE_EXCLUSIONS__/$filter_tmpl_exclusions_hash{$cur_filter_to_create_hash{'TemplateUsed'}}/g;
    CPNL::COMMON::in_array($cur_filter_to_create_hash{'MustProduct'}, @CPNL::COMMON::must_types) and $new_line =~ s/__MPNAME__/$cur_filter_to_create_hash{'MustProduct'}/g;
        !CPNL::COMMON::in_array($cur_filter_to_create_hash{'MustProduct'}, @CPNL::COMMON::must_types) and $new_line =~ s/__MPNAME__//g;

    print FIC_OUT_FILTERS "$new_line";
  }
  $count_filters_in_file = $count_filters_in_file + 1;
}

######################################################
# Close files
######################################################
print FIC_OUT_FILTERS "</ENTITYLIST>\n";
close(FIC_OUT_FILTERS);
print FIC_OUT_FILTERS_SEC "</ENTITYLIST>\n";
close(FIC_OUT_FILTERS_SEC);
close(FIC_OUT_GRID_CMD_FILE);
close(FIC_IN_PARAMS_CVID);

######################################################
# Remove inactive Splitted Filters
######################################################
my ${cpnl_delete} = CPNL::COMMON::prepare_query($CPNL::SQL::req_delete_inactive_splitted_params);
${cpnl_delete}->execute();
${cpnl_delete}->finish;

######################################################
# Delete unnecessary files
######################################################
if ($count_filters == 0) {
  print "\nThere are no filters to import : Removing Import files :\n";

  print '  '.${out_filters_filename}."\n";
  unlink(${out_filters_filename});

  print '  '.${out_filters_sec_filename}."\n";
  unlink(${out_filters_sec_filename});

  print '  '.${CPNL::ENV_VARS::SUMMITSPOOLDIR}.'/'.${_GRID_CMD_FILE}."\n";
  unlink(${CPNL::ENV_VARS::SUMMITSPOOLDIR}.'/'.${_GRID_CMD_FILE});
}

######################################################
# End
######################################################
&CPNL::COMMON::db_disconnect();
print "=> End of filters creation.\n";

######################################################
# Function
######################################################
sub calculateNextDate(){
            my ($Date) = @_;
            my $Year = substr($Date, 0, 4);
            my $Month = substr($Date, 4, 2) - 1;
            my $Day = substr($Date, 6, 2);
            my $Date_int = timelocal("0","0","0","$Day","$Month","$Year");
            my $NextDate_int = $Date_int + (24 * 60 * 60);
            my $NextDate = sprintf "%04d%02d%02d", (localtime($NextDate_int))[5] + 1900, (localtime($NextDate_int))[4] + 1, (localtime($NextDate_int))[3];
            return $NextDate;
}

sub get_tradedate_count_list(){
            my ($Book, $TradeType, $Closing) = @_;
            my %TradeDate_Hash;
            # Get the exclusions of the COMMON template, to add them to the SQL queries
            my %tmpl_excl_hash;
            my ${tmpl_excl_db} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_common_tmpl_excl);
            $tmpl_excl_db->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
            while (my @tmpl_excl = $tmpl_excl_db->fetchrow_array) {
                        my ($tmpl_name, $element, $value) = @tmpl_excl;

                        $tmpl_excl_hash{$element} = $value;
            }

            my $sql_query_env_excl_tmpl = '';
            while ( my ($cur_excl_element, $cur_excl_value) = each %tmpl_excl_hash) {
                        my $like_sign = '';
                        my $foreach_count = 0;

                        #### /!\ Ameliorer : prendre en compte plus que dmENV par exemple
                        if ($cur_excl_element eq "ProductName") { next; }
                        if ($cur_excl_element eq "TradeStatus") { next; }
                        if ($cur_excl_element eq "DealID") { $cur_excl_element = "DealId"; }
                        if ($cur_excl_element eq "Customer") { $cur_excl_element = "Cust"; }

                        if ($cur_excl_value =~ m/-/) {
                                   my @excl_value_array = split(/-/, $cur_excl_value);

                                   $foreach_count = 0;
                                   $sql_query_env_excl_tmpl .= " AND ( \n";
                                   foreach my $cur_excl (@excl_value_array) {
                                               if ($cur_excl =~ m/%/) {
                                                           $like_sign = 'not like';
                                               }
                                               else {
                                                           $like_sign = '<>';
                                               }

                                               if ($cur_excl eq "") { next; }
                                               if ($foreach_count != 0) { $sql_query_env_excl_tmpl .= "  AND"; }
                                               $sql_query_env_excl_tmpl .= "            E.".$cur_excl_element." ".$like_sign." '".$cur_excl."' \n";
                                               $foreach_count++;
                                   }
                                   $sql_query_env_excl_tmpl .= " ) \n";
                        }
                        elsif ($cur_excl_value =~ m/\+/) {
                                   my @excl_value_array = split(/\+/, $cur_excl_value);

                                   $foreach_count = 0;
                                   $sql_query_env_excl_tmpl .= " AND ( \n";
                                   foreach my $cur_excl (@excl_value_array) {

                                               if ($cur_excl =~ m/%/) {
                                                           $like_sign = 'like';
                                               }
                                               else {
                                                           $like_sign = '=';
                                               }

                                               if ($cur_excl eq "") { next; }
                                               if ($foreach_count != 0) { $sql_query_env_excl_tmpl .= "  OR"; }
                                               $sql_query_env_excl_tmpl .= "            E.".$cur_excl_element." ".$like_sign." '".$cur_excl."' \n";
                                               $foreach_count++;
                                   }
                                   $sql_query_env_excl_tmpl .= " ) \n";
                        }
                        else {
                                   $sql_query_env_excl_tmpl .= " AND      E.".$cur_excl_element." = '".$cur_excl_value."' \n";
                        }
            }

            # Get the Matdate, stored in DB
            my $MatDate_db = $CPNL::COMMON::DbConnection->prepare($CPNL::SQL::req_select_mr_min_matdate) or  CPNL::COMMON::mydie($DBI::errstr."\n");
            $MatDate_db->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
            my $MatDate = $MatDate_db->fetchrow_array;
            $MatDate_db->finish;

  # Get the FinalMaturity, stored in DB
            my $FinalMaturity_db = $CPNL::COMMON::DbConnection->prepare($CPNL::SQL::req_select_mr_min_finalmaturity) or  CPNL::COMMON::mydie($DBI::errstr."\n");
            $FinalMaturity_db->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
            my $FinalMaturity = $FinalMaturity_db->fetchrow_array;
            $FinalMaturity_db->finish;

            # Get the list of TradeTypes
            my $list_trade_types = $CPNL::COMMON::DbConnection->prepare($CPNL::SQL::req_select_TTYPES) or CPNL::COMMON::mydie($DBI::errstr."\n");
            $list_trade_types->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
            while (my @trade_types = $list_trade_types->fetchrow_array) {
                        my ($trade_type, $owner_table) = @trade_types;

                        $trade_type eq $TradeType and do{
                                   %TradeDate_Hash = &prepare_get_infos_from_db($TradeType, $owner_table, $MatDate,$FinalMaturity, $Closing, $Book, $sql_query_env_excl_tmpl);
                        };

                        $trade_type eq "MUST" and CPNL::COMMON::in_array($TradeType, @CPNL::COMMON::must_types) and do {
                                   %TradeDate_Hash = &prepare_get_infos_from_db($TradeType, $owner_table, $MatDate,$FinalMaturity, $Closing, $Book, $sql_query_env_excl_tmpl);
                        };
            }
#          %TradeDate_Hash = &prepare_get_infos_from_db($TradeType, $owner_table, $MatDate, $Closing, $Book, $sql_query_env_excl_tmpl);
            return %TradeDate_Hash;
}

sub prepare_get_infos_from_db(){
            my ($trade_type, $owner_table, $start_date,$FinalMaturity, $closing, $book, $sql_query_env_excl_tmpl) = @_;
            my %data_hash;
            my $sql_query;
            my $query = "";

            if (CPNL::COMMON::in_array(CPNL::COMMON::trim(${trade_type}), @CPNL::COMMON::must_types)) {
                        $sql_query = "SELECT E.TradeDate, count(E.TradeDate) as TradesCount \n";
                        $sql_query .= " FROM  dmENV E, dmBOOK BOO, dmMPTRDATA MP";
                        $sql_query .= " WHERE E.TradeId = MP.TradeId \n";
                $sql_query .= " AND E.Audit_Version = MP.Audit_Version \n";
                $sql_query .= " AND E.dmOwnerTable = MP.dmOwnerTable \n";
                        $sql_query .= " AND MP.MPDefName = '$trade_type' \n";
            }
            else {
                        $sql_query = "SELECT E.TradeDate, count(E.TradeDate) as TradesCount \n";
                        $sql_query .= " FROM  dmENV E, dmBOOK BOO ";
            }

            if ( $trade_type eq "DLPMT" ) {
                        #$sql_query .= " \n WHERE 1=1 \n";
                        # TradeType excluded by MOA
                        return 0;
            }
            elsif ( $trade_type eq "FUT" || $trade_type eq "LOPT") {
                        $sql_query .= ", dmFUTURE FU \n";
                        $sql_query .= " WHERE FU.Audit_Version = E.Audit_Version \n";
                        $sql_query .= " AND   FU.TradeId = E.TradeId \n";
                        $sql_query .= " AND   FU.FutOpt = 'O' \n" if ( $trade_type eq "LOPT" );
                        $sql_query .= " AND   FU.FutOpt = 'F' \n" if ( $trade_type eq "FUT" );
            }
            elsif ( $trade_type eq "BOND" ) {
                        $sql_query .= ", dmBOND BON, dmSEC S, dmSASSET SA \n";
                        $sql_query .= " WHERE BON.Audit_Version = E.Audit_Version \n";
                        $sql_query .= " AND   BON.TradeId = E.TradeId \n";
                        $sql_query .= " AND   S.Audit_Current = 'Y' \n";
                        $sql_query .= " AND   S.Sec = BON.Sec \n";
                        $sql_query .= " AND   SA.Audit_Version = S.Audit_Version \n";
                        $sql_query .= " AND   SA.dmAssetId = S.dmAssetId \n";
                        $sql_query .= " AND   SA.MatDate > '$start_date' \n";
            }
            elsif ( $trade_type eq "SWOPT" || $trade_type eq "FXOPT" || $trade_type eq "BONDOP" ) {
                        $sql_query .= ", dmOPTION O, dmBACK BAC \n";
                        $sql_query .= " WHERE O.dmOwnerTable = E.dmOwnerTable \n";
                        $sql_query .= " AND   O.Audit_Version = E.Audit_Version \n";
                        $sql_query .= " AND   O.TradeId = E.TradeId \n";
                        $sql_query .= " AND  (O.ExpDate > '$start_date' AND O.Exercise > '$start_date') \n";
                        $sql_query .= " AND   BAC.dmOwnerTable = E.dmOwnerTable \n";
                        $sql_query .= " AND   BAC.Audit_Version = E.Audit_Version \n";
                        $sql_query .= " AND   BAC.TradeId = E.TradeId \n";
                        $sql_query .= " AND   BAC.TermEffDate > '$start_date' \n";
            }
            elsif ( $trade_type eq "FXSWAP" || $trade_type eq "FXSPOT" || $trade_type eq "FXFWD" ) {
                        $sql_query .= ", dmFOREX FO \n";
                        $sql_query .= " WHERE FO.dmOwnerTable = E.dmOwnerTable \n";
                        $sql_query .= " AND   FO.Audit_Version = E.Audit_Version \n";
                        $sql_query .= " AND   FO.TradeId = E.TradeId \n";
                        $sql_query .= " AND   FO.Valdate > '$start_date' \n";
            }
            elsif ( $trade_type eq "MM" || $trade_type eq "FRA" || $trade_type eq "SWAP" || $trade_type eq "IRG" || $trade_type eq "EXOTIC" || $trade_type eq "REPO" ) {
                        $sql_query .= ", dmASSET A \n";
                        $sql_query .= " WHERE E.TradeId = A.TradeId \n";
                        $sql_query .= " AND   E.dmOwnerTable = A.dmOwnerTable \n";
                        $sql_query .= " AND   E.Audit_Version = A.Audit_Version \n";
                        if ( $trade_type eq "FRA" ) {
                                   $sql_query .= " AND   A.EffDate > '$start_date' \n";
                        }
                        elsif ( $trade_type eq "REPO" ) {
                                   $sql_query .= " AND   (A.MatDate > '$start_date' OR A.MatDate like '%OPEN%') \n";
                        }
                        else {
                                   $sql_query .= " AND   A.MatDate > '$start_date' \n";
                        }
            }

            $sql_query .= " AND   E.Audit_Current = 'Y' \n";
            $sql_query .= " AND   E.dmOwnerTable = '$owner_table' \n";
            $sql_query .= " AND   E.TradeStatus IN (".$CPNL::ENV_VARS::_FILTERS_SQL_TRADESTATUS.") \n";
            $sql_query .= " AND   E.Book = '$book' \n";
  $sql_query .= " AND   E.FinalMaturity > '$FinalMaturity' \n";

            # Get From DB all the specifics of Exclusions like Desks and Boost we never want to calculate PNL on.
            my $sql_query_env_excl = '';
            my @env_excl_array = split(/;/, $CPNL::ENV_VARS::_FILTERS_SQL_ENV_EXCL);
            foreach my $cur_env_excl (@env_excl_array) {
              $sql_query_env_excl .= " AND   E.".$cur_env_excl." \n";
            }

            $sql_query .= $sql_query_env_excl;
            $sql_query .= $sql_query_env_excl_tmpl;

            $sql_query .= " AND   BOO.Book = E.Book \n";
            $sql_query .= " AND   BOO.Audit_Current = 'Y' \n";
            $sql_query .= " AND   BOO.cdmClosing = '$closing' \n";

            $sql_query .= " GROUP BY E.TradeDate \n";
            $sql_query .= " ORDER BY E.TradeDate \n";

            print "sql_query = $sql_query.\n";
            my $Result = $CPNL::COMMON::DbConnection->prepare($sql_query) or  CPNL::COMMON::mydie($DBI::errstr."\n");
            print "after prepare prepare_get_infos_from_db.\n";
            $Result->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
            print "after execute prepare_get_infos_from_db.\n";
            while (my @Result = $Result->fetchrow_array){
                        my ($TradeDate, $TradeCount) = @Result;
                        $data_hash{$TradeDate} = $TradeCount;
            }
            return %data_hash;
}