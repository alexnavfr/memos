
sub generate_report($$){    
    my ($href, $out, $corp) = @_;
     my $job     = $href->{ "job" };
    my $report  = $href->{ "report" };
       print $corp "#=========================================\n";
    print $corp "#            REPORT ${job}                \n";
    print $corp "#=========================================\n";
     #---------------------
    # report
    #---------------------

    foreach my $item ( @$report )

    {

        my $id = $item->{ "id" };

       

        my $lref_missing_files  = $item->{  "missing_files"  };

        my $lref_valuing_errors = $item->{  "valuing_errors" };

        my $lref_funding_errors = $item->{  "funding_errors" };

        my $lref_error_log      = $item->{  "error_log"      };

                        my $lref_future_errors      = $item->{  "future_errors"      };

        my $lref_curves_errors  = $item->{  "curves_errors"  };

                        print STDOUT "@$lref_valuing_errors" . "@$lref_missing_files" ."\n" . ${id} . "@$lref_valuing_errors" . "@$lref_funding_errors" ;

                        print STDOUT @${lref_valuing_errors}  ."\n";

                       

                       

        if (  @$lref_missing_files  ||

              @$lref_valuing_errors ||

              @$lref_funding_errors ||

                                     @$lref_future_errors   ||

              @$lref_curves_errors )

        {

            print $out "#=========================================\n";

            print $out "#            R ${job}                \n";

                   print $out "#=========================================\n";

 

 

            print $out "\n#-------------------------------------------------------\n";

            print $out "# ${id}                                                   \n";

            print $out "#-------------------------------------------------------\n";

      

            print $corp "\n#-------------------------------------------------------\n";

 

                                  

                                   my $FilterName=substr(${id}, 5,10);

            my @taskresult = &sqlRequest("SELECT Book FROM  Tot WHERE Active=1 AND RT='x' and fn='$fn;");

 

                                   print $corp "# ${id}                                                   \n";

                                   print  $corp "BOOK=$taskresult[0][0]\n";

            print  $out "BOOK=$taskresult[0][0]\n";

            print $corp "#-------------------------------------------------------\n";

            if ( @$lref_valuing_errors )

            {

 

                my $num_errors = @$lref_valuing_errors;  # get the numbers

                print $out "#----------------------- PL ---------------------------\n";

                print $out @$lref_valuing_errors;

                                       print $out "#-------------------------------------------------------\n";

                                               print $corp "#----------------------- P&L ---------------------------\n";

               

                if ( $num_errors > 5)

                {

                    print $corp join ( "\n", @$lref_valuing_errors[0..4]);

                    print $corp "\n and ( $num_errors - 5 ) errors.";

                }

                else

                {

                    print $corp @$lref_valuing_errors;

                }

                                       print $corp "#-------------------------------------------------------\n";

 

            }

           

           if (  @$lref_future_errors )

            {

                my $num_errors = @$lref_future_errors;  # get the numbers

                print $corp "#---------------------- FUT ------------------------\n";

                print $corp @$lref_future_errors;

                print $corp "#-------------------------------------------------------\n";


            }

                           

                                  

                                   if ( @$lref_funding_errors )

            {

                print $out "#---------------------- fun ------------------------\n";

                print $out @$lref_funding_errors;

                                               print $out "#-------------------------------------------------------\n";


            }

           

            print $out @$lref_error_log if ( ! $g_light );

            my @error_log;

                                   if ( ! $g_light ) {

                                              my $element=@$lref_error_log;

                                               while ($element >= 0) {

                                               @$lref_error_log[$element]=~ s/(..):(..):(..)\.(...)//;

                                               @$lref_error_log[$element]=~ s/(..)\/(..)\/(..)\ //;

                                              

                                               @$lref_error_log[$element]=~ s/^\ //g;

 

                                               #@error_log = grep ( ! Enumerated Value  not found for Enumeration  , @lref_error_log[$element]   );

 

                                               $element=$element-1;

                                               }

 

                                     # print $corp @$lref_error_log;

                                     # print $corp @$error_log;

                                   }

            if ( @$lref_curves_errors )

            {

                print $out "#---------------------- cur --------------------------\n";

                print $out @$lref_curves_errors;

                print $out "#-------------------------------------------------------\n";

                                              

                print $corp "#---------------------- cur --------------------------\n";

                print $corp "\n";

 

                                               my $element=@$lref_curves_errors;

                                               while ($element >= 0) {

                                               @$lref_curves_errors[$element]=~ s/(..):(..):(..)\.(...)//;

                                               @$lref_curves_errors[$element]=~ s/(..)\/(..)\/(..)\/(..)//;

                                               @$lref_curves_errors[$element]=~ s/^\ //g;

                                               $element=$element-1;

                                              

                                               }

                                               my $element=@$lref_curves_errors;

                                               my $curseur=0;

                                               my @test=();

                                               while ($curseur < $element ) {

                                               if (@$lref_curves_errors[$curseur] eq @$lref_curves_errors[$curseur+1])

                                               {

                                               $curseur=$curseur+1;

                                               } else {

                                               $test[$curseur]=@$lref_curves_errors[$curseur-1] ;

                                               $curseur=$curseur+1;

                                               }

                                              

                                               }

                print $corp  @test;

                print $corp "#-------------------------------------------------------\n";

 

            }

           

                                  

                                  

                                  

            if ( @$lref_missing_files )

            {

                print $out "\n#------------------ missing files ----------------------\n";

                print $out @$lref_missing_files;

                print $out "#-------------------------------------------------------\n";

             

                                              

                                       #print $corp "\n#------------------ missing files ----------------------\n";

                #print $corp @$lref_missing_files;

                #print $corp "#-------------------------------------------------------\n";

 

            }

        }

                        #print $corp $out;

    }

}

